# SeqLisp - A Lisp interpreter written in Seq
#
# Requires: seqc (the Seq compiler) on PATH

default:
    @just --list

# Build the REPL and file runner
build:
    @echo "Building SeqLisp REPL..."
    @mkdir -p target
    seqc src/repl.seq -o target/seqlisp
    seqc src/run.seq -o target/seqlisp-run
    @echo "Built: target/seqlisp (REPL), target/seqlisp-run (file runner)"

# Run the interactive REPL
repl: build
    ./target/seqlisp

# Run a Lisp file
run file: build
    ./target/seqlisp-run {{file}}

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

# Run all examples
examples: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running Lisp examples..."
    for example in examples/*.lisp; do
        echo "=== $(basename $example) ==="
        ./target/seqlisp-run "$example"
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
