# SeqLisp Build System
#
# Requires: seqc (the Seq compiler) on PATH
# Note: seqc has embedded stdlib - no local stdlib directory needed

default:
    @just --list

# Run all tests
test:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running SeqLisp tests..."
    for test in test_*.seq; do
        name=$(basename "$test" .seq)
        echo "  $name..."
        seqc "$test" -o "/tmp/$name" && "/tmp/$name" > /dev/null
    done
    echo "✅ All tests passed!"

# Run tests with output
test-verbose:
    #!/usr/bin/env bash
    set -euo pipefail
    for test in test_*.seq; do
        name=$(basename "$test" .seq)
        echo "=== $name ==="
        seqc "$test" -o "/tmp/$name" && "/tmp/$name"
        echo ""
    done

# Build the REPL (coming soon)
build:
    @echo "REPL not yet implemented"

# Clean build artifacts
clean:
    rm -f /tmp/test_*
