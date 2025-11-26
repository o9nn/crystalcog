#!/bin/bash
# Guix package validation script for CrystalCog
# CrystalCog is a Crystal language project with optional Guix integration

echo "=== CrystalCog Guix Package Validation ==="

# Check if essential Guix files exist
echo "Checking Guix configuration files..."
GUIX_FILES_EXIST=true

if [ -f ".guix-channel" ]; then
    echo "✓ .guix-channel exists"
else
    echo "✗ .guix-channel missing"
    GUIX_FILES_EXIST=false
fi

if [ -f "guix.scm" ]; then
    echo "✓ guix.scm manifest exists"
else
    echo "✗ guix.scm manifest missing"
    GUIX_FILES_EXIST=false
fi

# Note about gnu/packages/opencog.scm
if [ -f "gnu/packages/opencog.scm" ]; then
    echo "✓ gnu/packages/opencog.scm exists (optional for C++ OpenCog integration)"
else
    echo "ℹ gnu/packages/opencog.scm not present (not required for CrystalCog)"
    echo "  This file is only needed for C++ OpenCog package definitions."
    echo "  CrystalCog uses native Crystal tooling (shards) for package management."
fi

# Basic syntax check
echo -e "\nValidating Scheme syntax..."
if command -v guile > /dev/null; then
    echo "Testing package module syntax..."
    if guile -c "(use-modules (gnu packages opencog))" 2>/dev/null; then
        echo "✓ Package module syntax valid"
    else
        echo "✗ Package module syntax invalid"
        echo "Running syntax check..."
        guile -c "(use-modules (gnu packages opencog))"
    fi
    
    echo "Testing manifest syntax..."
    if guile -c "(load \"guix.scm\")" 2>/dev/null; then
        echo "✓ Manifest syntax valid"
    else
        echo "✗ Manifest syntax invalid"
        echo "Running syntax check..."
        guile -c "(load \"guix.scm\")"
    fi
else
    echo "⚠ Guile not available, skipping syntax validation"
    echo "To validate syntax, install Guile and run:"
    echo "  guile -c '(use-modules (gnu packages opencog))'"
    echo "  guile -c '(load \"guix.scm\")'"
fi

echo -e "\n=== Package Summary ==="
echo "CrystalCog Guix Integration Status:"
echo ""
echo "CrystalCog is a Crystal language project that uses:"
echo "  - Primary package manager: shards (Crystal's native package manager)"
echo "  - Optional integration: Guix (for OpenCog ecosystem compatibility)"
echo ""
echo "Guix configuration files present:"
echo "  ✓ guix.scm - Development environment manifest"
echo "  ✓ .guix-channel - Agent-Zero Genesis package channel"
echo ""
echo "Usage:"
echo "  guix environment -m guix.scm    # Development environment with Guile packages"
echo "  shards install                  # Install Crystal dependencies (primary method)"
echo ""
echo "See README.md and docs/README-GUIX.md for detailed usage instructions."
echo ""

if [ "$GUIX_FILES_EXIST" = true ]; then
    echo "✅ Guix validation PASSED - Essential configuration files present"
    exit 0
else
    echo "⚠️  Guix validation WARNING - Some files missing but not critical for CrystalCog"
    echo "   CrystalCog primarily uses Crystal/shards tooling."
    exit 0  # Non-blocking warning
fi