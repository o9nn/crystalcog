# CrystalCog - Development Guide for Claude

## Project Overview

CrystalCog is a comprehensive rewrite of the OpenCog artificial intelligence framework in Crystal language. This project provides better performance, memory safety, and maintainability while preserving all functionality of the original OpenCog system.

## Quick Commands

```bash
# Run all tests
./scripts/test-runner.sh --all

# Run specific component tests
crystal spec spec/atomspace/
crystal spec spec/pln/
crystal spec spec/nlp/

# Build main executable
crystal build src/crystalcog.cr

# Build with release optimizations
crystal build src/crystalcog.cr --release

# Run benchmarks
crystal run --release benchmarks/atomspace_benchmark.cr

# Format code
crystal tool format src/ spec/

# Check dependencies
shards install
```

## Project Structure

```
src/
├── cogutil/           # Core utilities (logging, config, profiling)
├── atomspace/         # Hypergraph knowledge representation
├── pln/               # Probabilistic Logic Networks
├── ure/               # Unified Rule Engine
├── opencog/           # Main reasoning interface
├── cogserver/         # Network server with REST API
├── pattern_matching/  # Advanced pattern matching engine
├── pattern_mining/    # Pattern discovery algorithms
├── nlp/               # Natural language processing
├── moses/             # Evolutionary optimization (MOSES)
├── attention/         # Attention allocation (ECAN)
├── agent-zero/        # Distributed agent networks
├── learning/          # Concept learning and generalization
├── ml/                # Machine learning integration
├── ai_integration/    # External AI system bridges
├── spatial/           # Spatial reasoning (Phase 6)
└── temporal/          # Temporal reasoning (Phase 7)

spec/                  # Crystal spec tests
examples/              # Demo programs and test utilities
benchmarks/            # Performance benchmarking
scripts/               # Build and deployment scripts
docs/                  # Documentation
```

## Key Architecture Concepts

### AtomSpace
The core hypergraph-based knowledge representation:
- **Atoms**: Basic units - Nodes (concepts) and Links (relationships)
- **TruthValues**: Probabilistic strength/confidence pairs
- **AttentionValues**: Priority-based resource allocation
- **Persistence**: Multiple backends (RocksDB, PostgreSQL, SQLite, File)

### Reasoning Systems
- **PLN**: Probabilistic Logic Networks - uncertain inference
- **URE**: Unified Rule Engine - forward/backward chaining
- **MOSES**: Meta-Optimizing Semantic Evolutionary Search

### NLP Pipeline
- **Tokenizer**: Text tokenization
- **LinkGrammar**: Syntactic parsing
- **DependencyParser**: Dependency tree construction
- **SemanticUnderstanding**: Meaning extraction
- **LanguageGeneration**: Text generation from atoms

## Code Style Guidelines

### Crystal Conventions
- Use `snake_case` for methods and variables
- Use `PascalCase` for classes and modules
- Use `SCREAMING_SNAKE_CASE` for constants
- Prefer `property` for getters/setters
- Use `struct` for value types, `class` for reference types

### Module Pattern
```crystal
module ComponentName
  VERSION = "0.1.0"

  class MainClass
    getter atomspace : AtomSpace::AtomSpace

    def initialize(@atomspace : AtomSpace::AtomSpace)
    end
  end
end
```

### Error Handling
```crystal
class ComponentException < Exception
end

raise ComponentException.new("Descriptive error message")
```

### Logging
```crystal
CogUtil::Logger.debug("Debug message")
CogUtil::Logger.info("Info message")
CogUtil::Logger.warn("Warning message")
CogUtil::Logger.error("Error message")
```

## Development Status

### Completed Phases (1-5)
- ✅ **Phase 1**: Foundation (cogutil, atomspace core)
- ✅ **Phase 2**: Core Reasoning (PLN, URE, opencog)
- ✅ **Phase 3**: Specialized AI (MOSES, pattern mining)
- ✅ **Phase 4**: Language Processing (NLP pipeline, link grammar)
- ✅ **Phase 5**: Persistence & Integration (storage backends, distributed)

### Current Phase (6): Robotics and Embodiment
- 🔧 Spatial reasoning and navigation systems
- 🔧 Goal-oriented behavior planning
- 🔧 Sensory-motor coordination
- 🔧 Virtual world integration

### Upcoming Phase (7): Advanced AI Features
- ⏳ Neural-symbolic integration
- ⏳ Multi-agent coordination
- ⏳ Temporal reasoning and event processing
- ⏳ Explanation generation

## Testing Approach

### Spec Organization
```
spec/
├── atomspace/       # AtomSpace unit tests
├── pln/             # PLN reasoning tests
├── ure/             # URE engine tests
├── nlp/             # NLP pipeline tests
├── moses/           # MOSES optimization tests
├── attention/       # Attention allocation tests
├── cogserver/       # Network API tests
├── integration/     # Cross-component tests
└── performance/     # Performance benchmarks
```

### Running Tests
```bash
# All specs
crystal spec

# Specific component
crystal spec spec/atomspace/

# Verbose output
crystal spec --verbose

# With RocksDB disabled (if not installed)
DISABLE_ROCKSDB=1 crystal spec
```

## Common Patterns

### Creating AtomSpace with Atoms
```crystal
atomspace = AtomSpace::AtomSpace.new

# Add nodes
concept = atomspace.add_concept_node("dog")
predicate = atomspace.add_predicate_node("is_mammal")

# Add links with truth values
inheritance = atomspace.add_inheritance_link(
  concept,
  atomspace.add_concept_node("animal"),
  AtomSpace::SimpleTruthValue.new(0.9, 0.8)
)
```

### PLN Reasoning
```crystal
pln = PLN::Engine.new(atomspace)
pln.add_rule(PLN::DeductionRule.new)
results = pln.forward_chain(max_steps: 10)
```

### Pattern Matching
```crystal
matcher = PatternMatching::PatternMatcher.new(atomspace)
pattern = PatternMatching::Pattern.new
results = matcher.match(pattern)
```

### NLP Processing
```crystal
processor = NLP::TextProcessor.new(atomspace)
atoms = processor.process("The dog is a mammal.")
```

## Dependencies

### Required
- **Crystal** >= 1.10.1
- **sqlite3** (crystal-lang/crystal-sqlite3)
- **pg** (will/crystal-pg)

### Optional
- **RocksDB** for high-performance storage (set `DISABLE_ROCKSDB=1` if unavailable)
- **PostgreSQL** for production deployments

## Key Files Reference

### Core Entry Points
- `src/crystalcog.cr` - Main application entry
- `src/atomspace/atomspace_main.cr` - AtomSpace module
- `src/pln/pln.cr` - PLN reasoning engine
- `src/cogserver/cogserver_main.cr` - CogServer network API

### Configuration
- `shard.yml` - Project dependencies and targets
- `.github/workflows/` - CI/CD configuration

### Documentation
- `docs/DEVELOPMENT-ROADMAP.md` - Full project roadmap
- `docs/API_DOCUMENTATION.md` - API reference
- `docs/INDEX.md` - Documentation index

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `DISABLE_ROCKSDB` | Skip RocksDB storage backend | unset |
| `CRYSTALCOG_LOG_LEVEL` | Logging verbosity | INFO |
| `COGSERVER_PORT` | CogServer HTTP port | 18080 |
| `COGSERVER_TELNET_PORT` | CogServer Telnet port | 17001 |

## CI/CD Notes

The project uses GitHub Actions for CI:
- Automatic Crystal installation
- Full test suite execution
- Code formatting checks
- Performance benchmarks on release

## Troubleshooting

### RocksDB Not Found
```bash
export DISABLE_ROCKSDB=1
crystal spec
```

### Crystal Not Installed
```bash
./scripts/install-crystal.sh
```

### Memory Issues on Large Tests
Run tests individually or use `--no-color` flag for reduced output.

## Contributing

1. Create feature branch from `main`
2. Follow code style guidelines
3. Add tests for new functionality
4. Run full test suite before PR
5. Update documentation as needed

## License

AGPL-3.0 - See LICENSE file
