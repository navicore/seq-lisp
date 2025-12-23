# SeqLisp - A Lisp interpreter written in Seq
#
# Requires: seqc (the Seq compiler) on PATH

default:
    @just --list

# Build SeqLisp
build:
    @echo "Building SeqLisp..."
    @mkdir -p target
    seqc build src/repl.seq -o target/seqlisp
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
        seqc build "$test" -o "target/tests/$name" && "./target/tests/$name" > /dev/null
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
        seqc build "$test" -o "target/tests/$name" && "./target/tests/$name"
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
    # Combine framework + all test files + runner into temp file
    tmp=$(mktemp)
    trap "rm -f $tmp" EXIT
    cat lib/test.lisp \
        tests/lisp/core/arithmetic.lisp \
        tests/lisp/core/comparison.lisp \
        tests/lisp/core/predicates.lisp \
        tests/lisp/core/lists.lisp \
        tests/lisp/functions/closures.lisp \
        tests/lisp/functions/higher_order.lisp \
        tests/lisp/functions/recursion.lisp \
        tests/lisp/functions/tco.lisp \
        tests/lisp/special_forms/conditionals.lisp \
        tests/lisp/special_forms/sequencing.lisp \
        tests/lisp/special_forms/quoting.lisp \
        tests/lisp/special_forms/error_handling.lisp \
        tests/lisp/macros/defmacro.lisp \
        tests/lisp/macros/quasiquote.lisp \
        tests/lisp/macros/gensym.lisp \
        tests/lisp/edge_cases/parser.lisp \
        tests/lisp/edge_cases/io.lisp \
        tests/lisp/all.lisp \
        > "$tmp"
    ./target/seqlisp "$tmp"

# Run a specific test file with framework
lisp-run file: build
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp)
    trap "rm -f $tmp" EXIT
    cat lib/test.lisp {{file}} > "$tmp"
    ./target/seqlisp "$tmp"

# Full CI: test + build + lisp-test
ci: test build lisp-test
    @echo "CI passed!"

# Safe eval - for testing expressions with bounded output (prevents infinite loops)
safe-eval expr: build
    #!/usr/bin/env bash
    tmp_out=$(mktemp)
    trap "rm -f $tmp_out" EXIT
    timeout 3 ./target/seqlisp /dev/stdin <<< '{{expr}}' > "$tmp_out" 2>&1 || true
    head -20 "$tmp_out"
    lines=$(wc -l < "$tmp_out")
    if [ "$lines" -gt 20 ]; then
        echo "... (truncated, $lines total lines)"
    fi
