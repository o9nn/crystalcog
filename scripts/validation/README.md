# CrystalCog Validation Scripts

This directory contains validation and integration test scripts for the CrystalCog project.

## Available Scripts

### CogServer Integration Testing

#### `test_cogserver_integration.sh`
Comprehensive integration test for the CogServer Network API.

**Tests**:
- HTTP REST API endpoints (7 endpoints)
- Telnet command interface (4 commands)
- WebSocket protocol upgrade
- Atom CRUD operations
- Error handling and validation

**Usage**:
```bash
# Requires a running CogServer instance on localhost:17001 (telnet) and localhost:18080 (HTTP/WebSocket)
./scripts/validation/test_cogserver_integration.sh
```

**Prerequisites**:
- CogServer must be running before executing the test
- `jq` utility must be installed for JSON parsing
- `curl` must be available for HTTP requests

#### `run_cogserver_integration_test.sh` (Recommended)
Automated wrapper that builds the CogServer, starts it, runs the integration tests, and cleans up.

**Usage**:
```bash
# This is the easiest way to run the integration tests
./scripts/validation/run_cogserver_integration_test.sh
```

**What it does**:
1. Verifies Crystal is installed
2. Installs Crystal dependencies (shards)
3. Builds the cogserver binary
4. Starts the cogserver in the background
5. Waits for server initialization
6. Runs the integration test suite
7. Stops the cogserver and cleans up

**Exit codes**:
- 0: All tests passed
- 1: Tests failed or server didn't start

### Other Validation Scripts

#### `test_integration.sh`
General integration testing script.

#### `test_nlp_structure.sh`
Natural language processing structure validation.

#### `validate-guix-packages.sh`
Validates Guix package definitions.

#### `validate-setup-production.sh`
Validates production environment setup.

#### `validate_integration_test.sh`
General integration test validation.

## Test Requirements

### System Dependencies
- Crystal 1.10.1 or later
- jq (JSON processor)
- curl (HTTP client)
- libevent-dev (for Crystal HTTP server)

### Crystal Dependencies
- sqlite3 (database support)
- pg (PostgreSQL support)
- db (database abstraction)

## Running Tests

### Quick Start
```bash
# Run all cogserver integration tests (easiest method)
./scripts/validation/run_cogserver_integration_test.sh
```

### Manual Testing
```bash
# 1. Install Crystal if needed
./scripts/install-crystal.sh

# 2. Install dependencies
shards install

# 3. Build cogserver
DISABLE_ROCKSDB=1 crystal build src/cogserver/cogserver_main.cr -o cogserver_bin

# 4. Start cogserver in background
./cogserver_bin &
COGSERVER_PID=$!

# 5. Wait for initialization
sleep 5

# 6. Run integration test
./scripts/validation/test_cogserver_integration.sh

# 7. Stop cogserver
kill $COGSERVER_PID
```

### CI/CD Integration
```bash
# For automated CI/CD pipelines
./scripts/validation/run_cogserver_integration_test.sh
```

## Test Results

See [COGSERVER_INTEGRATION_VALIDATION.md](../../docs/COGSERVER_INTEGRATION_VALIDATION.md) for detailed validation results and performance metrics.

## Troubleshooting

### Server Won't Start
- Check if ports 17001 and 18080 are available
- Verify libevent-dev is installed: `sudo apt-get install libevent-dev`
- Check server logs in `/tmp/cogserver_test.log`

### Build Failures
- Ensure Crystal is properly installed: `crystal --version`
- Install dependencies: `shards install`
- For RocksDB issues, use: `DISABLE_ROCKSDB=1` before the build command

### Test Failures
- Ensure cogserver is running: `curl http://localhost:18080/status`
- Check if jq is installed: `which jq`
- Verify network connectivity to localhost

## Contributing

When adding new validation scripts:
1. Follow the naming convention: `test_*.sh` or `validate_*.sh`
2. Add appropriate error handling with `set -e`
3. Include colored output for better readability
4. Document the script in this README
5. Make scripts executable: `chmod +x script_name.sh`
6. Test thoroughly before committing

## Documentation

For detailed validation reports and results:
- [CogServer Integration Validation](../../docs/COGSERVER_INTEGRATION_VALIDATION.md)
- [Development Roadmap](../../docs/DEVELOPMENT-ROADMAP.md)
- [Main README](../../README.md)
