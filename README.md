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
- **Definitions**: `define`, `lambda`
- **Conditionals**: `if`
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

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - How the interpreter works
- [Roadmap](docs/ROADMAP.md) - Future plans and vision

## License

MIT
