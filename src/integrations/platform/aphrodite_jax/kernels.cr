# CPU kernels for the native engine. Weights are BF16 rows widened to F32
# per row, so each weight row is read once per batch of tokens (decode is
# memory-bound). With -Dpreview_mt, row ranges run on CRYSTAL_WORKERS threads.

module AphroditeJax
  module Kernels
    # Run block(start, stop) over 0...total in chunks, in parallel when
    # compiled with -Dpreview_mt.
    {% if flag?(:preview_mt) %}
      def self.parallel_for(total : Int32, &block : Int32, Int32 ->) : Nil
        workers = (ENV["CRYSTAL_WORKERS"]?.try(&.to_i?) || 4).clamp(1, 64)
        if workers == 1 || total < 64
          block.call(0, total)
          return
        end
        chunk = (total + workers - 1) // workers
        done = Channel(Exception?).new(workers)
        launched = 0
        (0...workers).each do |w|
          start = w * chunk
          break if start >= total
          stop = Math.min(start + chunk, total)
          launched += 1
          spawn(same_thread: false) do
            begin
              block.call(start, stop)
              done.send(nil)
            rescue ex
              done.send(ex)
            end
          end
        end
        launched.times { (err = done.receive) && raise err }
      end
    {% else %}
      def self.parallel_for(total : Int32, & : Int32, Int32 ->) : Nil
        yield 0, total
      end
    {% end %}

    # out[t, r] = sum_c x[t, c] * w[r, c] for t in 0...n.
    def self.matmul(dst : Slice(Float32), x : Slice(Float32), w : Slice(UInt16), n : Int32, rows : Int32, cols : Int32) : Nil
      parallel_for(rows) do |r0, r1|
        row = Slice(Float32).new(cols)
        rp = row.to_unsafe
        xp = x.to_unsafe
        op = dst.to_unsafe
        (r0...r1).each do |r|
          wp = w.to_unsafe + r.to_i64 * cols
          cols.times { |c| rp[c] = (wp[c].to_u32 << 16).unsafe_as(Float32) }
          n.times do |t|
            xt = xp + t.to_i64 * cols
            acc0 = 0_f32
            acc1 = 0_f32
            acc2 = 0_f32
            acc3 = 0_f32
            c = 0
            while c + 3 < cols
              acc0 += xt[c] * rp[c]
              acc1 += xt[c + 1] * rp[c + 1]
              acc2 += xt[c + 2] * rp[c + 2]
              acc3 += xt[c + 3] * rp[c + 3]
              c += 4
            end
            while c < cols
              acc0 += xt[c] * rp[c]
              c += 1
            end
            op[t.to_i64 * rows + r] = (acc0 + acc1) + (acc2 + acc3)
          end
        end
      end
    end

    def self.rmsnorm(dst : Slice(Float32), x : Slice(Float32), weight : Slice(Float32), eps : Float32) : Nil
      sum = 0_f64
      x.each { |v| sum += v.to_f64 * v }
      scale = (1.0 / Math.sqrt(sum / x.size + eps)).to_f32
      x.size.times { |i| dst[i] = x[i] * scale * weight[i] }
    end

    def self.dot(a : Pointer(Float32), b : Pointer(Float32), n : Int32) : Float32
      acc = 0_f32
      n.times { |i| acc += a[i] * b[i] }
      acc
    end

    # In-place softmax over the first `n` values.
    def self.softmax(v : Slice(Float32), n : Int32) : Nil
      max = v[0]
      (1...n).each { |i| max = v[i] if v[i] > max }
      sum = 0_f32
      n.times do |i|
        e = Math.exp(v[i] - max)
        v[i] = e
        sum += e
      end
      n.times { |i| v[i] /= sum }
    end

    @[AlwaysInline]
    def self.silu(x : Float32) : Float32
      x / (1_f32 + Math.exp(-x))
    end
  end
end
