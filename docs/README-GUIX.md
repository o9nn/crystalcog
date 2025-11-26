# CrystalCog Guix Packaging

This directory contains GNU Guix package definitions for CrystalCog and related components.

## Package Structure

CrystalCog provides two package module locations:

1. **gnu/packages/crystalcog.scm** - Main CrystalCog package definitions following Guix conventions
2. **agent-zero/packages/cognitive.scm** - Agent-Zero cognitive packages with Guile bindings

## Using the Packages

### As a Guix Channel

1. Add this repository as a Guix channel by creating/editing `~/.config/guix/channels.scm`:

```scheme
(cons* (channel
        (name 'crystalcog)
        (url "https://github.com/cogpy/crystalcog.git")
        (branch "main")
        (introduction
         (make-channel-introduction
          "COMMIT_HASH_HERE"
          (openpgp-fingerprint "FINGERPRINT_HERE"))))
       %default-channels)
```

2. Update Guix to include the new channel:

```bash
guix pull
```

### Using the Manifest

To create a development environment with all CrystalCog packages:

```bash
guix environment -m guix.scm
```

Or to install the packages:

```bash
guix install -m guix.scm
```

### Installing Individual Packages

```bash
# Main CrystalCog platform
guix install crystalcog

# Core utilities
guix install crystalcog-cogutil

# AtomSpace hypergraph database
guix install crystalcog-atomspace

# Guile bindings for specific components
guix install guile-pln guile-ecan guile-moses
```

## Package Structure

### Core Packages (gnu/packages/crystalcog.scm)

- **crystalcog**: Main Crystal-based cognitive architecture platform
  - Includes all components: AtomSpace, PLN, URE, MOSES, NLP, etc.
- **crystalcog-cogutil**: Core utilities (logging, config, random)
- **crystalcog-atomspace**: Hypergraph database and reasoning engine

### Agent-Zero Cognitive Packages (agent-zero/packages/cognitive.scm)

- **opencog**: Re-exported crystalcog package for compatibility
- **ggml**: Tensor library for machine learning integration
- **guile-pln**: Guile bindings for Probabilistic Logic Networks
- **guile-ecan**: Guile bindings for attention allocation
- **guile-moses**: Guile bindings for evolutionary optimization
- **guile-pattern-matcher**: Guile bindings for pattern matching
- **guile-relex**: Guile bindings for natural language processing

## Development

### Testing Package Definitions

To validate the package definitions:

```bash
# Run the validation script
./scripts/validation/validate-guix-packages.sh

# Test syntax (requires Guile)
guile -c "(add-to-load-path \".\") (use-modules (gnu packages crystalcog))"

# Build a package (requires Guix)
guix build crystalcog --no-substitutes
```

### Building from Source

The packages are configured to build from the CrystalCog Git repository. To modify 
the source or use local development versions, you can:

1. Fork the packages and modify the source URLs
2. Use `guix environment` with `--ad-hoc crystal` to work with development versions
3. Create local package variants using `package/inherit`

## Dependencies

The CrystalCog packages require several dependencies that are automatically 
handled by Guix:

- **Build tools**: Crystal compiler, shards (Crystal dependency manager), pkg-config
- **Libraries**: PostgreSQL, SQLite (for persistent storage)
- **Runtime**: Crystal runtime libraries

For Guile bindings:
- **Guile**: Guile 3.0 or later
- **guile-lib**: Guile utility libraries

## License

The package definitions are licensed under GPL v3+, matching the OpenCog
project licensing. CrystalCog itself is licensed under AGPL-3.0.