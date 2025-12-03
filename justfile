# SeqLisp - A Lisp interpreter written in Seq
#
# Requires: seqc (the Seq compiler) on PATH

default:
    @just --list

# Build the REPL
build:
    @echo "Building SeqLisp REPL..."
    @mkdir -p target
    seqc src/repl.seq -o target/seqlisp
    @echo "Built: target/seqlisp"

# Run the REPL
run: build
    ./target/seqlisp

# Run interpreter tests
test:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running SeqLisp tests..."
    mkdir -p target
    for test in src/test_*.seq; do
        name=$(basename "$test" .seq)
        echo "  $name..."
        seqc "$test" -o "target/$name" && "./target/$name" > /dev/null
    done
    echo "All tests passed!"

# Run tests with output
test-verbose:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p target
    for test in src/test_*.seq; do
        name=$(basename "$test" .seq)
        echo "=== $name ==="
        seqc "$test" -o "target/$name" && "./target/$name"
        echo ""
    done

# Run a Lisp example
example file: build
    @echo "Running {{file}}..."
    @echo "{{file}}" | ./target/seqlisp

# Run all examples
examples: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running Lisp examples..."
    for example in examples/*.lisp; do
        echo "=== $(basename $example) ==="
        cat "$example" | ./target/seqlisp
        echo ""
    done

# Clean build artifacts
clean:
    rm -rf target

# Format check (placeholder for future linter)
fmt:
    @echo "No formatter yet - contributions welcome!"

# Full CI: test + build
ci: test build
    @echo "CI passed!"
