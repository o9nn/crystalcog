# CrystalCog Guix Packaging

This directory contains GNU Guix package definitions for CrystalCog and Agent-Zero components.

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

Or use the newer `guix shell` command:

```bash
guix shell -m guix.scm
```

### Installing Individual Packages

Note: Individual package installation is currently not supported as these are
placeholder packages for development environment setup. The packages will be
properly installable once CrystalCog reaches production maturity.

For now, use the manifest-based development environment:

```bash
# Enter development shell with all dependencies
guix shell -m guix.scm
```

## Package Structure

CrystalCog provides the following Guix packages:

- **opencog**: Core cognitive architecture implemented in Crystal
- **ggml**: Tensor library integration for machine learning
- **guile-pln**: Probabilistic Logic Networks Guile bindings
- **guile-ecan**: Economic Attention Network Guile bindings  
- **guile-moses**: MOSES evolutionary learning Guile bindings
- **guile-pattern-matcher**: Pattern matching engine Guile bindings
- **guile-relex**: Natural language processing Guile bindings

## Development

### Testing Package Definitions

To test the package definitions locally:

```bash
# Validate package module syntax
guix shell guile -- guile -c "(use-modules (agent-zero packages cognitive))"

# Test manifest loading
guix shell guile -- guile -c "(load \"guix.scm\")"

# Run validation script
./scripts/validation/validate-guix-packages.sh
```

### Building from Source

The packages are currently placeholders for development environment setup.
To build CrystalCog from source:

```bash
# Enter Guix development shell
guix shell -m guix.scm

# Build CrystalCog components
crystal build src/crystalcog.cr
crystal spec

# Or use the test runner
./scripts/test-runner.sh --all
```

## Dependencies

The CrystalCog development environment includes:

- **Build tools**: CMake, GCC toolchain, pkg-config
- **Libraries**: Boost, Guile 3.0
- **Crystal Language**: Installed via the project's installation scripts
- **Cognitive packages**: PLN, ECAN, MOSES, pattern matcher, RelEx bindings

Note: Crystal itself is not yet available in Guix, so it should be installed
using the project's installation scripts (`./scripts/install-crystal.sh`).

## License

The package definitions are licensed under AGPL v3+, matching the CrystalCog
project licensing.