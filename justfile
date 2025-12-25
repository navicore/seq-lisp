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
    for example in examples/*.slisp; do
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
    cat lib/test.slisp \
        tests/lisp/core/arithmetic.slisp \
        tests/lisp/core/comparison.slisp \
        tests/lisp/core/predicates.slisp \
        tests/lisp/core/lists.slisp \
        tests/lisp/core/strings.slisp \
        tests/lisp/core/floats.slisp \
        tests/lisp/core/json.slisp \
        tests/lisp/core/lsp_builtins.slisp \
        tests/lisp/functions/closures.slisp \
        tests/lisp/functions/higher_order.slisp \
        tests/lisp/functions/recursion.slisp \
        tests/lisp/functions/tco.slisp \
        tests/lisp/special_forms/conditionals.slisp \
        tests/lisp/special_forms/sequencing.slisp \
        tests/lisp/special_forms/quoting.slisp \
        tests/lisp/special_forms/error_handling.slisp \
        tests/lisp/macros/defmacro.slisp \
        tests/lisp/macros/quasiquote.slisp \
        tests/lisp/macros/gensym.slisp \
        tests/lisp/edge_cases/parser.slisp \
        tests/lisp/edge_cases/io.slisp \
        tests/lisp/edge_cases/suggestions.slisp \
        tests/lisp/all.slisp \
        > "$tmp"
    ./target/seqlisp "$tmp"

# Run a specific test file with framework
lisp-run file: build
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp)
    trap "rm -f $tmp" EXIT
    cat lib/test.slisp {{file}} > "$tmp"
    ./target/seqlisp "$tmp"

# Run LSP integration tests
lsp-test: build
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running LSP integration tests..."
    failed=0

    # Test 1: Initialize handshake
    echo -n "  test_initialize... "
    output=$(cat tests/lsp/test_initialize.txt | ./target/seqlisp lib/lsp.slisp 2>&1)
    if echo "$output" | grep -q '"result":{"capabilities"' && echo "$output" | grep -q '"id":2,"result"'; then
        echo "PASS"
    else
        echo "FAIL"
        echo "Output: $output"
        failed=1
    fi

    # Test 2: didOpen publishes diagnostics
    echo -n "  test_didopen... "
    output=$(cat tests/lsp/test_didopen.txt | ./target/seqlisp lib/lsp.slisp 2>&1)
    if echo "$output" | grep -q 'publishDiagnostics' && echo "$output" | grep -q '"uri":"file:///test.slisp"'; then
        echo "PASS"
    else
        echo "FAIL"
        echo "Output: $output"
        failed=1
    fi

    # Test 3: didChange publishes diagnostics
    echo -n "  test_didchange... "
    output=$(cat tests/lsp/test_didchange.txt | ./target/seqlisp lib/lsp.slisp 2>&1)
    # Should get two publishDiagnostics (one for open, one for change)
    count=$(echo "$output" | grep -c 'publishDiagnostics' || true)
    if [ "$count" -ge 2 ]; then
        echo "PASS"
    else
        echo "FAIL (expected 2 publishDiagnostics, got $count)"
        echo "Output: $output"
        failed=1
    fi

    # Test 4: Unknown method returns error
    echo -n "  test_unknown_method... "
    output=$(cat tests/lsp/test_unknown_method.txt | ./target/seqlisp lib/lsp.slisp 2>&1)
    if echo "$output" | grep -q '"error"' && echo "$output" | grep -q 'Method not found'; then
        echo "PASS"
    else
        echo "FAIL"
        echo "Output: $output"
        failed=1
    fi

    # Test 5: Empty contentChanges is handled gracefully
    echo -n "  test_empty_changes... "
    output=$(cat tests/lsp/test_empty_changes.txt | ./target/seqlisp lib/lsp.slisp 2>&1)
    # Should not crash, should still respond to shutdown
    if echo "$output" | grep -q '"id":2,"result"'; then
        echo "PASS"
    else
        echo "FAIL"
        echo "Output: $output"
        failed=1
    fi

    if [ "$failed" -eq 0 ]; then
        echo "All LSP tests passed!"
    else
        echo "Some LSP tests failed!"
        exit 1
    fi

# Full CI: test + build + lisp-test + lsp-test
ci: test build lisp-test lsp-test
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

# Installation directories (override with PREFIX=... just install)
PREFIX := env_var_or_default("PREFIX", env_var("HOME") + "/.local")
BINDIR := PREFIX + "/bin"
DATADIR := PREFIX + "/share/seqlisp"

# Install seqlisp and seqlisp-lsp
install: build
    #!/usr/bin/env bash
    set -euo pipefail

    BINDIR="{{BINDIR}}"
    DATADIR="{{DATADIR}}"

    echo "Installing SeqLisp..."
    echo "  Binary:  $BINDIR/seqlisp"
    echo "  Data:    $DATADIR/"
    echo "  LSP:     $BINDIR/seqlisp-lsp"

    # Create directories
    mkdir -p "$BINDIR"
    mkdir -p "$DATADIR/lib"

    # Install binary
    cp ./target/seqlisp "$BINDIR/seqlisp"
    chmod +x "$BINDIR/seqlisp"

    # Install library files
    cp -r ./lib/* "$DATADIR/lib/"

    # Create seqlisp-lsp wrapper script
    printf '%s\n' \
        '#!/bin/sh' \
        '# SeqLisp Language Server' \
        'SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"' \
        'DATADIR="${SCRIPT_DIR}/../share/seqlisp"' \
        'if [ ! -f "$DATADIR/lib/lsp.slisp" ]; then' \
        '    echo "Error: lsp.slisp not found at $DATADIR/lib/lsp.slisp" >&2' \
        '    exit 1' \
        'fi' \
        'exec "$SCRIPT_DIR/seqlisp" "$DATADIR/lib/lsp.slisp" "$@"' \
        > "$BINDIR/seqlisp-lsp"
    chmod +x "$BINDIR/seqlisp-lsp"

    echo ""
    echo "Installation complete!"
    echo "Make sure $BINDIR is in your PATH."

# Uninstall seqlisp
uninstall:
    #!/usr/bin/env bash
    set -euo pipefail

    BINDIR="{{BINDIR}}"
    DATADIR="{{DATADIR}}"

    echo "Uninstalling SeqLisp..."
    rm -f "$BINDIR/seqlisp"
    rm -f "$BINDIR/seqlisp-lsp"
    rm -rf "$DATADIR"
    echo "Done."
