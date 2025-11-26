# CrystalCog Validation Scripts

This directory contains validation scripts for testing and verifying CrystalCog components.

## Available Scripts

### `test_cogserver_integration.sh` - CogServer Network API Integration Test

Tests the CogServer Network API functionality including HTTP REST endpoints, telnet interface, WebSocket protocol, and atom operations.

**Prerequisites:**
- Crystal compiler installed
- `curl` command-line tool
- `jq` JSON processor
- CogServer must be running on localhost:18080 (HTTP) and localhost:17001 (Telnet)

**Usage:**
```bash
./test_cogserver_integration.sh
```

**What it tests:**
- ✅ HTTP REST API endpoints (7 endpoints)
  - Status endpoint (`/status`)
  - Version endpoint (`/version`)
  - Ping endpoint (`/ping`)
  - AtomSpace endpoint (`/atomspace`)
  - Atoms endpoint (`/atoms`)
  - Sessions endpoint (`/sessions`)
  - 404 error handling
- ✅ Telnet command interface (4 commands)
  - Help command
  - Info command
  - AtomSpace command
  - Stats command
- ✅ WebSocket protocol
  - WebSocket upgrade handshake
  - Invalid upgrade rejection
- ✅ Atom CRUD operations
  - Create atom via POST
  - Verify atom existence

**Starting the test server:**
```bash
# From repository root
DISABLE_ROCKSDB=1 crystal run examples/tests/start_test_cogserver.cr
```

**Example output:**
```
🧪 CogServer Network API Integration Test
==========================================
📡 Testing server endpoints on localhost:18080...

🔍 Testing HTTP Endpoints:
   📊 Status endpoint...
      ✅ Status endpoint working
   📋 Version endpoint...
      ✅ Version endpoint working
...
✨ Integration test completed successfully!
```

**Validation Status:**
- ✅ Script functionality validated
- ✅ All test categories passing (5/5)
- ✅ Dependency compatibility confirmed
- ✅ Error handling robust with graceful fallbacks

### `validate_integration_test.sh` - Comprehensive Validation Test

Meta-validation script that validates the `test_cogserver_integration.sh` script itself. This ensures the integration test meets all quality requirements.

**Prerequisites:**
- Crystal compiler installed
- All dependencies from `test_cogserver_integration.sh`

**Usage:**
```bash
# From repository root
./scripts/validation/validate_integration_test.sh
```

**What it validates:**
1. **Dependency Checking**
   - Verifies `curl`, `jq`, and `crystal` are available
   - Reports version information

2. **Script Functionality**
   - Confirms script exists and is executable
   - Validates test coverage categories

3. **Build Compatibility**
   - Builds CogServer with DISABLE_ROCKSDB=1 flag
   - Verifies successful compilation

4. **Test Coverage Analysis**
   - HTTP REST API tests
   - Telnet command interface tests
   - WebSocket protocol tests
   - Atom CRUD operation tests
   - Error handling validation

5. **Functional Validation**
   - Starts CogServer for testing
   - Executes integration test script
   - Verifies all endpoints respond correctly
   - Confirms success messages and feature summaries

**Example output:**
```
🔄 Package Script Validation: test_cogserver_integration.sh
==========================================================
✅ Checking dependencies...
   • curl: curl 8.5.0
   • jq: jq-1.7
   • crystal: Crystal 1.10.1

✅ Validating script functionality...
   • Script exists and is executable

✅ Checking CogServer build compatibility...
   • Building CogServer...
   • CogServer built successfully

✅ Analyzing script test coverage...
   • HTTP REST API tests: ✓
   • Telnet command interface tests: ✓
   • WebSocket protocol tests: ✓
   • Atom CRUD operation tests: ✓
   • Error handling validation: ✓
   • Total test categories: 5/5

✅ Running functional validation...
   • CogServer is ready after 7 seconds ✓
   • Integration test PASSED ✓

🎯 VALIDATION COMPLETE
======================================
✅ Script functionality: VALIDATED
✅ Dependency compatibility: CONFIRMED
✅ Guix environment tests: AVAILABLE
✅ Package documentation: UPDATED
```

**Validation Status:**
- ✅ Meta-validation complete
- ✅ All quality gates passing
- ✅ Documentation updated

### `test_integration.sh` - General Integration Test

Tests Crystal implementation components including specs and example tests.

**Usage:**
```bash
./test_integration.sh
```

### `test_nlp_structure.sh` - NLP Structure Test

Validates Natural Language Processing component structure and functionality.

**Usage:**
```bash
./test_nlp_structure.sh
```

### `validate-guix-packages.sh` - Guix Package Validation

Validates Guix package definitions and dependencies for the Agent-Zero ecosystem.

**Usage:**
```bash
./validate-guix-packages.sh
```

### `validate-setup-production.sh` - Production Setup Validation

Validates production deployment setup and configuration.

**Usage:**
```bash
./validate-setup-production.sh
```

## Running All Validation Tests

To run all validation tests:

```bash
# From repository root
for script in scripts/validation/*.sh; do
    echo "Running: $script"
    bash "$script"
done
```

## Continuous Integration

These validation scripts are designed to work in CI/CD environments:
- Exit code 0 indicates success
- Exit code non-zero indicates failure
- Detailed output for debugging
- Graceful handling of missing dependencies

## Troubleshooting

### CogServer won't start
```bash
# Check if Crystal is installed
crystal --version

# Try building with DISABLE_ROCKSDB flag
DISABLE_ROCKSDB=1 crystal build src/cogserver/cogserver_main.cr -o cogserver

# Start the server manually
./cogserver
```

### Tests fail with connection errors
```bash
# Ensure CogServer is running first
DISABLE_ROCKSDB=1 crystal run examples/tests/start_test_cogserver.cr &

# Wait for server to be ready (check logs)
sleep 5

# Then run tests
./scripts/validation/test_cogserver_integration.sh
```

### Missing dependencies
```bash
# Install jq (Ubuntu/Debian)
sudo apt-get install jq

# Install curl (usually pre-installed)
sudo apt-get install curl

# Install Crystal
./scripts/install-crystal.sh --method auto
```

## Contributing

When adding new validation scripts:
1. Follow the naming convention: `test_*.sh` or `validate_*.sh`
2. Make scripts executable: `chmod +x scripts/validation/your_script.sh`
3. Add comprehensive error handling
4. Provide clear output with ✅ and ❌ indicators
5. Update this README with script documentation
6. Ensure scripts work in CI/CD environments
