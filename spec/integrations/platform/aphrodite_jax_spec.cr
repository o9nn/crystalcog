require "spec"
require "http/client"
require "../../../src/integrations/platform/aphrodite_jax_server"

# Writes a tiny random Qwen3 (2 layers, hidden 16) plus a byte-level BPE
# tokenizer with two merges and ChatML specials into a temp directory.
module TinyQwen3
  VOCAB = 261 # 256 bytes + "he" + "ll" + 3 specials

  def self.write(dir : String, seed = 42) : String
    Dir.mkdir_p(dir)
    bytes = AphroditeJax::Tokenizer.bytes_to_unicode
    vocab = {} of String => Int32
    bytes.each_with_index { |c, i| vocab[c.to_s] = i }
    vocab["he"] = 256
    vocab["ll"] = 257
    tokenizer = {
      "normalizer"    => {"type" => "NFC"},
      "pre_tokenizer" => {"type" => "ByteLevel"},
      "model"         => {"type" => "BPE", "vocab" => vocab, "merges" => [["h", "e"], ["l", "l"]]},
      "added_tokens"  => [{"id" => 258, "content" => "<|endoftext|>", "special" => true},
                         {"id" => 259, "content" => "<|im_start|>", "special" => true},
                         {"id" => 260, "content" => "<|im_end|>", "special" => true}],
    }
    File.write(File.join(dir, "tokenizer.json"), tokenizer.to_json)
    File.write(File.join(dir, "config.json"), {
      "model_type" => "qwen3", "hidden_size" => 16, "num_hidden_layers" => 2, "num_attention_heads" => 4,
      "num_key_value_heads" => 2, "head_dim" => 4, "intermediate_size" => 32, "vocab_size" => VOCAB,
      "rope_theta" => 10000, "rms_norm_eps" => 1e-6, "tie_word_embeddings" => true,
      "eos_token_id" => 260, "bos_token_id" => 258,
    }.to_json)

    shapes = {"model.embed_tokens.weight" => [VOCAB, 16], "model.norm.weight" => [16]}
    2.times do |i|
      p = "model.layers.#{i}."
      shapes["#{p}input_layernorm.weight"] = [16]
      shapes["#{p}post_attention_layernorm.weight"] = [16]
      shapes["#{p}self_attn.q_norm.weight"] = [4]
      shapes["#{p}self_attn.k_norm.weight"] = [4]
      shapes["#{p}self_attn.q_proj.weight"] = [16, 16]
      shapes["#{p}self_attn.k_proj.weight"] = [8, 16]
      shapes["#{p}self_attn.v_proj.weight"] = [8, 16]
      shapes["#{p}self_attn.o_proj.weight"] = [16, 16]
      shapes["#{p}mlp.gate_proj.weight"] = [32, 16]
      shapes["#{p}mlp.up_proj.weight"] = [32, 16]
      shapes["#{p}mlp.down_proj.weight"] = [16, 32]
    end
    rng = Random.new(seed)
    tensors = shapes.map do |name, shape|
      count = shape.product
      values = Array(Float32).new(count) { |_| name.includes?("norm") ? 1_f32 : (rng.rand(-0.5..0.5)).to_f32 }
      {name, shape, values}
    end
    write_safetensors(File.join(dir, "model.safetensors"), tensors)
    dir
  end

  def self.write_safetensors(path : String, tensors : Array({String, Array(Int32), Array(Float32)}), dtype = "BF16")
    header = {} of String => JSON::Any
    data = IO::Memory.new
    tensors.each do |(name, shape, values)|
      start = data.pos
      values.each do |v|
        if dtype == "F32"
          data.write_bytes(v, IO::ByteFormat::LittleEndian)
        else
          data.write_bytes(AphroditeJax.f32_to_bf16(v), IO::ByteFormat::LittleEndian)
        end
      end
      header[name] = JSON.parse({"dtype" => dtype, "shape" => shape, "data_offsets" => [start, data.pos]}.to_json)
    end
    json = header.to_json
    File.open(path, "w") do |f|
      f.write_bytes(json.bytesize.to_u64, IO::ByteFormat::LittleEndian)
      f << json
      f.write(data.to_slice)
    end
  end
end

private def tiny_dir : String
  TinyQwen3.write(File.tempname("tiny-qwen3"))
end

describe AphroditeJax::Safetensors do
  it "reads BF16 and F32 tensors with shapes" do
    dir = File.tempname("st")
    Dir.mkdir_p(dir)
    begin
      path = File.join(dir, "a.safetensors")
      TinyQwen3.write_safetensors(path, [{"w", [2, 2], [1.5_f32, -2.0_f32, 0.25_f32, 3.0_f32]}], "F32")
      st = AphroditeJax::Safetensors.new(path)
      st.shape("w").should eq([2_i64, 2_i64])
      st.f32("w").to_a.should eq([1.5_f32, -2.0_f32, 0.25_f32, 3.0_f32])
      expect_raises(KeyError) { st.bf16("missing") }
    ensure
      FileUtils.rm_rf(dir)
    end
  end

  it "converts between f32, bf16 and f16" do
    AphroditeJax.bf16_to_f32(AphroditeJax.f32_to_bf16(3.140625_f32)).should eq(3.140625_f32)
    AphroditeJax.f16_to_f32(0x3C00_u16).should eq(1.0_f32)
    AphroditeJax.f16_to_f32(0xC000_u16).should eq(-2.0_f32)
  end
end

describe AphroditeJax::Tokenizer do
  it "applies merges, splits specials and round-trips text" do
    dir = tiny_dir
    begin
      t = AphroditeJax::Tokenizer.from_file(File.join(dir, "tokenizer.json"))
      ids = t.encode("<|im_start|>hello<|im_end|>")
      ids.first.should eq(259)
      ids.last.should eq(260)
      ids.should contain(256) # "he"
      ids.should contain(257) # "ll"
      t.decode(ids).should eq("<|im_start|>hello<|im_end|>")
      t.decode(ids, skip_special: true).should eq("hello")
      text = "Héllo, wörld! 日本 😊\n\tok"
      t.decode(t.encode(text)).should eq(text)
    ensure
      FileUtils.rm_rf(dir)
    end
  end
end

describe AphroditeJax::Qwen3 do
  it "gives the same logits through the KV cache as a full recompute" do
    dir = tiny_dir
    begin
      a = AphroditeJax::Qwen3.load(dir, 32)
      b = AphroditeJax::Qwen3.load(dir, 32)
      toks = [259, 104, 256, 257, 111]
      a.forward(toks[0, 4], 0)
      step = a.forward([toks[4]], 4)
      full = b.forward(toks, 0)
      step.size.should eq(TinyQwen3::VOCAB)
      (0...step.size).max_of { |i| (step[i] - full[i]).abs }.should be < 1e-5
    ensure
      FileUtils.rm_rf(dir)
    end
  end

  it "rejects contexts beyond max_len and non-qwen3 configs" do
    dir = tiny_dir
    begin
      m = AphroditeJax::Qwen3.load(dir, 4)
      expect_raises(ArgumentError, /exceeds/) { m.forward([1, 2, 3, 4, 5], 0) }
      expect_raises(ArgumentError, /only qwen3/) do
        AphroditeJax::Qwen3Config.new(JSON.parse(%({"model_type":"llama"})))
      end
    ensure
      FileUtils.rm_rf(dir)
    end
  end
end

describe AphroditeJax::Generator do
  it "generates deterministically, honours max_tokens, stops and streams" do
    dir = tiny_dir
    begin
      g = AphroditeJax::Generator.load(dir, 128)
      greedy = AphroditeJax::SamplingParams.new(temperature: 0.0, max_tokens: 12, ignore_eos: true)
      first = g.generate("hello", greedy)
      g.generate("hello", greedy).text.should eq(first.text) # also exercises prefix reuse
      first.completion_tokens.should eq(12)
      first.finish_reason.should eq("length")

      pieces = [] of String
      streamed = g.generate("hello", greedy) { |p| pieces << p }
      pieces.join.should eq(streamed.text)
      streamed.text.should eq(first.text)

      if first.text.size > 2
        stop = first.text[1, 1]
        cut = g.generate("hello", AphroditeJax::SamplingParams.new(temperature: 0.0, max_tokens: 12, stop: [stop], ignore_eos: true))
        cut.finish_reason.should eq("stop")
        cut.text.includes?(stop).should be_false
      end

      seeded = AphroditeJax::SamplingParams.new(temperature: 1.0, top_p: 0.9, max_tokens: 8, seed: 5_i64, ignore_eos: true)
      g.generate("hello", seeded).text.should eq(g.generate("hello", seeded).text)
    ensure
      FileUtils.rm_rf(dir)
    end
  end

  it "samples greedily with top_k 1 and builds ChatML prompts" do
    dir = tiny_dir
    begin
      g = AphroditeJax::Generator.load(dir, 64)
      logits = Slice(Float32).new(TinyQwen3::VOCAB) { |i| i == 42 ? 5_f32 : 0_f32 }
      params = AphroditeJax::SamplingParams.new(temperature: 1.0, top_k: 1)
      g.sample(logits.dup, params, Set(Int32).new, Random.new(1)).should eq(42)
      g.chat_prompt([{"user", "hi"}]).should eq("<|im_start|>user\nhi<|im_end|>\n<|im_start|>assistant\n<think>\n\n</think>\n\n")
    ensure
      FileUtils.rm_rf(dir)
    end
  end
end

describe AphroditeJax::Server do
  it "serves the OpenAI-compatible API" do
    dir = tiny_dir
    server = AphroditeJax::Server.new(AphroditeJax::Generator.load(dir, 256), "tiny-qwen3", requested_port: 0).start
    json = HTTP::Headers{"Content-Type" => "application/json"}
    begin
      models = JSON.parse(HTTP::Client.get("#{server.url}/v1/models").body)
      models["data"][0]["id"].should eq("tiny-qwen3")
      JSON.parse(HTTP::Client.get("#{server.url}/health").body)["status"].should eq("ok")

      req = {"messages" => [{"role" => "user", "content" => "hello"}], "max_tokens" => 6,
             "temperature" => 0, "ignore_eos" => true}
      chat = JSON.parse(HTTP::Client.post("#{server.url}/v1/chat/completions", headers: json, body: req.to_json).body)
      chat["choices"][0]["message"]["role"].should eq("assistant")
      chat["usage"]["completion_tokens"].should eq(6)
      text = chat["choices"][0]["message"]["content"].as_s

      sse = HTTP::Client.post("#{server.url}/v1/chat/completions", headers: json, body: req.merge({"stream" => true}).to_json).body
      lines = sse.split("\n").select(&.starts_with?("data: "))
      lines.last.should eq("data: [DONE]")
      deltas = lines[0..-2].map { |l| JSON.parse(l[6..])["choices"][0] }
      deltas.compact_map { |c| c["delta"]["content"]?.try(&.as_s) }.join.should eq(text)
      deltas.last["finish_reason"].should eq("length")

      comp = JSON.parse(HTTP::Client.post("#{server.url}/v1/completions", headers: json,
        body: {"prompt" => "hello", "max_tokens" => 4, "temperature" => 0, "ignore_eos" => true}.to_json).body)
      comp["choices"][0]["text"].as_s.should_not be_nil

      tok = JSON.parse(HTTP::Client.post("#{server.url}/v1/tokenize", headers: json, body: {"text" => "hello"}.to_json).body)
      detok = JSON.parse(HTTP::Client.post("#{server.url}/v1/detokenize", headers: json,
        body: {"tokens" => tok["tokens"]}.to_json).body)
      detok["text"].should eq("hello")

      HTTP::Client.post("#{server.url}/v1/chat/completions", headers: json, body: "[1]").status_code.should eq(400)
      HTTP::Client.get("#{server.url}/nope").status_code.should eq(404)
    ensure
      server.stop
      FileUtils.rm_rf(dir)
    end
  end
end

# Real-weights check against an independent reference implementation:
# set QWEN3_MODEL_DIR to a Qwen/Qwen3-0.6B snapshot to run it.
describe "AphroditeJax with Qwen3-0.6B weights" do
  if dir = ENV["QWEN3_MODEL_DIR"]?
    it "matches reference logits for <|im_start|>user\\nHello world" do
      logits = AphroditeJax::Qwen3.load(dir, 16).forward([151644, 872, 198, 9707, 1879], 0)
      top = (0...logits.size).to_a.sort_by { |i| -logits[i] }.first(5)
      top.should eq([198, 0, 4894, 11, 304])
      logits[198].should be_close(15.221, 0.01)
    end
  else
    pending "set QWEN3_MODEL_DIR to check real Qwen3-0.6B logits"
  end
end
