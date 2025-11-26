#!/bin/bash
# Validation script for CrystalCog Guix package definitions

echo "=== CrystalCog Guix Package Validation ==="

# Check if package files exist
echo "Checking package files..."
if [ -f "gnu/packages/crystalcog.scm" ]; then
    echo "✓ crystalcog.scm exists"
else
    echo "✗ crystalcog.scm missing"
    exit 1
fi

if [ -f "agent-zero/packages/cognitive.scm" ]; then
    echo "✓ cognitive.scm exists"
else
    echo "✗ cognitive.scm missing"
    exit 1
fi

if [ -f ".guix-channel" ]; then
    echo "✓ .guix-channel exists"
else
    echo "✗ .guix-channel missing"
    exit 1
fi

if [ -f "guix.scm" ]; then
    echo "✓ guix.scm manifest exists"
else
    echo "✗ guix.scm manifest missing"
    exit 1
fi

# Basic syntax check
echo -e "\nValidating Scheme syntax..."

# Check if Guix is installed (required for full validation)
if command -v guix > /dev/null; then
    echo "Guix detected - performing full syntax validation..."
    
    # Test CrystalCog package module
    echo "Testing CrystalCog package module syntax..."
    if guile -c "(add-to-load-path \".\") (use-modules (gnu packages crystalcog))" 2>/dev/null; then
        echo "✓ CrystalCog package module syntax valid"
    else
        echo "✗ CrystalCog package module syntax invalid"
        echo "Note: This validation requires full Guix installation"
        echo "Running syntax check..."
        guile -c "(add-to-load-path \".\") (use-modules (gnu packages crystalcog))" 2>&1 | head -20
    fi
    
    # Test Agent-Zero cognitive module
    echo "Testing Agent-Zero cognitive module syntax..."
    if guile -c "(add-to-load-path \".\") (use-modules (agent-zero packages cognitive))" 2>/dev/null; then
        echo "✓ Agent-Zero cognitive module syntax valid"
    else
        echo "✗ Agent-Zero cognitive module syntax invalid"
        echo "Note: This validation requires full Guix installation"
        echo "Running syntax check..."
        guile -c "(add-to-load-path \".\") (use-modules (agent-zero packages cognitive))" 2>&1 | head -20
    fi
    
    echo "Testing manifest syntax..."
    if guile -c "(add-to-load-path \".\") (load \"guix.scm\")" 2>/dev/null; then
        echo "✓ Manifest syntax valid"
    else
        echo "✗ Manifest syntax invalid"
        echo "Note: This validation requires full Guix installation"
        echo "Running syntax check..."
        guile -c "(add-to-load-path \".\") (load \"guix.scm\")" 2>&1 | head -20
    fi
elif command -v guile > /dev/null; then
    echo "Guile detected but Guix not installed - performing basic validation..."
    echo "⚠ Note: Full syntax validation requires Guix package manager"
    echo ""
    echo "Basic Scheme syntax validation (without Guix modules):"
    
    # Basic file syntax check without loading Guix modules
    for file in "gnu/packages/crystalcog.scm" "agent-zero/packages/cognitive.scm" "guix.scm"; do
        if guile --no-auto-compile -c "(with-input-from-file \"$file\" read)" 2>/dev/null >/dev/null; then
            echo "✓ $file: Basic syntax valid"
        else
            echo "✗ $file: Basic syntax errors detected"
            guile --no-auto-compile -c "(with-input-from-file \"$file\" read)"
        fi
    done
    
    echo ""
    echo "To perform full validation, install Guix:"
    echo "  wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh"
    echo "  chmod +x guix-install.sh"
    echo "  sudo ./guix-install.sh"
else
    echo "⚠ Guile not available, skipping syntax validation"
    echo "To validate syntax, install Guile and Guix, then run:"
    echo "  sudo apt-get install guile-3.0"
    echo "  # or install full Guix for complete validation"
fi

echo -e "\n=== Dependency Validation ==="
echo "Checking CrystalCog dependencies..."

# Check if Crystal is available (main dependency)
if command -v crystal > /dev/null; then
    CRYSTAL_VERSION=$(crystal --version | head -1)
    echo "✓ Crystal detected: $CRYSTAL_VERSION"
else
    echo "⚠ Crystal not detected (required for building CrystalCog packages)"
    echo "  Install with: ./scripts/install-crystal.sh"
fi

# Check if shards is available (Crystal dependency manager)
if command -v shards > /dev/null; then
    echo "✓ Shards detected (Crystal dependency manager)"
else
    echo "⚠ Shards not detected (comes with Crystal installation)"
fi

# Check for database dependencies mentioned in package definitions
if command -v psql > /dev/null || dpkg -l | grep -q postgresql 2>/dev/null; then
    echo "✓ PostgreSQL available"
else
    echo "⚠ PostgreSQL not detected (optional - needed for persistent storage)"
fi

if command -v sqlite3 > /dev/null || dpkg -l | grep -q sqlite3 2>/dev/null; then
    echo "✓ SQLite available"
else
    echo "⚠ SQLite not detected (optional - needed for persistent storage)"
fi

echo -e "\n=== Package Summary ==="
echo "CrystalCog Guix packages available:"
echo "  Core Packages:"
echo "    - crystalcog: Main Crystal cognitive architecture platform"
echo "    - crystalcog-cogutil: Core utilities (logging, config, random)"
echo "    - crystalcog-atomspace: Hypergraph database and reasoning"
echo ""
echo "  Agent-Zero Cognitive Packages:"
echo "    - opencog: Re-exported crystalcog package"
echo "    - ggml: Tensor library for machine learning"
echo "    - guile-pln: Guile bindings for PLN reasoning"
echo "    - guile-ecan: Guile bindings for attention allocation"
echo "    - guile-moses: Guile bindings for evolutionary optimization"
echo "    - guile-pattern-matcher: Guile bindings for pattern matching"
echo "    - guile-relex: Guile bindings for NLP"
echo ""
echo "Usage:"
echo "  guix environment -m guix.scm              # Development environment"
echo "  guix install crystalcog                   # Install main package"
echo "  guix install crystalcog-atomspace         # Install specific component"
echo ""
echo "See docs/README-GUIX.md for detailed usage instructions."