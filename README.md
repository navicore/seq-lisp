[![CI](https://github.com/navicore/seq-lisp/actions/workflows/ci.yml/badge.svg)](https://github.com/navicore/seq-lisp/actions/workflows/ci.yml)
[![Release](https://github.com/navicore/seq-lisp/actions/workflows/release.yml/badge.svg)](https://github.com/navicore/seq-lisp/actions/workflows/release.yml)

# SeqLisp

A Lisp interpreter written in [Seq](https://github.com/navicore/patch-seq), a stack-based concatenative programming language.

## Requirements

- `seqc` - The Seq compiler (install from [patch-seq](https://github.com/navicore/patch-seq))
- `just` - Command runner (optional, but recommended)

## Quick Start

```bash
# Build the REPL
just build

# Run the REPL
just run

# Or without just:
seqc src/repl.seq -o seqlisp
./seqlisp
```

## Project Structure

```
seq-lisp/
├── src/              # Seq source code (the interpreter)
│   ├── tokenizer.seq # Lexical analysis
│   ├── parser.seq    # S-expression parser
│   ├── sexpr.seq     # S-expression data types
│   ├── eval.seq      # Evaluator with environments
│   ├── repl.seq      # Interactive REPL
│   └── test_*.seq    # Interpreter tests
├── examples/         # Lisp programs
│   ├── hello.lisp
│   ├── factorial.lisp
│   └── fibonacci.lisp
├── justfile          # Build commands
└── README.md
```

## Commands

```bash
just build        # Build the REPL
just run          # Run the REPL
just test         # Run interpreter tests
just test-verbose # Run tests with output
just examples     # Run all Lisp examples
just clean        # Remove build artifacts
just ci           # Run tests and build
```

## Lisp Features

SeqLisp supports:

- **Arithmetic**: `+`, `-`, `*`, `/`
- **Comparisons**: `<`, `>`, `<=`, `>=`, `=`
- **Booleans**: `#t`, `#f`
- **Definitions**: `define`, `lambda`, `let`
- **Conditionals**: `if`, `cond`
- **Lists**: `cons`, `car`, `cdr`, `list`, `quote` (`'`), `append`, `reverse`, `length`, `nth`, `last`, `take`, `drop`
- **Higher-order**: `map`, `filter`, `fold`
- **Predicates**: `null?`, `number?`, `symbol?`, `list?`, `boolean?`
- **Sequencing**: `begin`
- **Output**: `print`

### Example

```lisp
;; Define factorial
(define factorial
  (lambda (n)
    (if (<= n 1)
        1
        (* n (factorial (- n 1))))))

(print (factorial 5))  ;; 120
```

### List Utilities

```lisp
;; Length of a list
(length '(1 2 3 4 5))    ;; => 5

;; Get nth element (0-indexed)
(nth 2 '(a b c d e))     ;; => c

;; Get last element
(last '(1 2 3 4 5))      ;; => 5

;; Take first n elements
(take 3 '(a b c d e))    ;; => (a b c)

;; Drop first n elements
(drop 2 '(a b c d e))    ;; => (c d e)
```

### Higher-Order Functions

```lisp
;; Map: transform each element
(map (lambda (x) (* x x)) '(1 2 3 4 5))
;; => (1 4 9 16 25)

;; Filter: keep elements matching predicate
(filter (lambda (x) (> x 2)) '(1 2 3 4 5))
;; => (3 4 5)

;; Fold: reduce list to single value
(fold (lambda (acc x) (+ acc x)) 0 '(1 2 3 4 5))
;; => 15
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - How the interpreter works
- [Roadmap](docs/ROADMAP.md) - Future plans and vision

## License

MIT
