# SeqLisp - A Lisp interpreter written in Seq
#
# Requires: seqc (the Seq compiler) on PATH

default:
    @just --list

# Build SeqLisp
build:
    @echo "Building SeqLisp..."
    @mkdir -p target
    seqc src/repl.seq -o target/seqlisp
    @echo "Built: target/seqlisp"

# Run the interactive REPL
repl: build
    ./target/seqlisp

# Run a Lisp file
run file: build
    ./target/seqlisp {{file}}

# Run Seq-level unit tests
test:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running Seq unit tests..."
    mkdir -p target/tests
    for test in tests/seq/test_*.seq; do
        name=$(basename "$test" .seq)
        echo "  $name..."
        seqc "$test" -o "target/tests/$name" && "./target/tests/$name" > /dev/null
    done
    echo "All Seq tests passed!"

# Run Seq tests with output
test-verbose:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p target/tests
    for test in tests/seq/test_*.seq; do
        name=$(basename "$test" .seq)
        echo "=== $name ==="
        seqc "$test" -o "target/tests/$name" && "./target/tests/$name"
        echo ""
    done

# Run all examples
examples: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running Lisp examples..."
    for example in examples/*.lisp; do
        echo "=== $(basename $example) ==="
        ./target/seqlisp "$example"
        echo ""
    done

# Clean build artifacts
clean:
    rm -rf target

# Format check (placeholder for future linter)
fmt:
    @echo "No formatter yet - contributions welcome!"

# Run Lisp test suite
lisp-test: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running SeqLisp Lisp tests..."
    # Combine framework + tests into temp file (workaround for stdin comment handling)
    tmp=$(mktemp)
    cat lib/test.lisp tests/all.lisp > "$tmp"
    ./target/seqlisp "$tmp"
    rm "$tmp"

# Run a specific test file with framework
lisp-run file: build
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp)
    cat lib/test.lisp {{file}} > "$tmp"
    ./target/seqlisp "$tmp"
    rm "$tmp"

# Full CI: test + build + lisp-test
ci: test build lisp-test
    @echo "CI passed!"
