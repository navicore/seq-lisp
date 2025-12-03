# SeqLisp

A Lisp interpreter written in [Seq](https://github.com/navicore/patch-seq), a stack-based concatenative programming language.

## Features

- **Numbers**: Integer literals
- **Symbols**: Variable lookup in environment
- **Arithmetic**: `+`, `-`, `*`, `/` (variadic)
- **Conditionals**: `(if cond then else)` - 0 is false, non-zero is true
- **Local bindings**: `(let name value body)`
- **Lambda**: `(lambda (params) body)` - anonymous functions with lexical scoping
- **Closures**: Lambdas capture their definition environment

## Examples

```lisp
; Arithmetic
(+ 1 2 3)           ; => 6
(* 2 (+ 3 4))       ; => 14

; Conditionals
(if 1 42 0)         ; => 42
(if 0 42 99)        ; => 99

; Local bindings
(let x 10 (+ x 5))  ; => 15

; Lambda
((lambda (x) (* x x)) 5)  ; => 25

; Closures
(let y 10
  ((lambda (x) (+ x y)) 5))  ; => 15
```

## Requirements

- `seqc` - The Seq compiler (from [patch-seq](https://github.com/navicore/patch-seq))

## Building

```bash
# Run tests
just test

# Run tests with output
just test-verbose
```

## Architecture

SeqLisp is implemented in ~400 lines of pure Seq:

- `sexpr.seq` - S-expression data types (variants)
- `tokenizer.seq` - Lexical analysis
- `parser.seq` - Recursive descent parser
- `eval.seq` - Tree-walking evaluator with environments

## Roadmap

- [ ] REPL (read-eval-print loop)
- [ ] Multi-parameter lambdas
- [ ] `define` for top-level bindings
- [ ] `quote` and list operations (`car`, `cdr`, `cons`)
- [ ] Compiler to Seq (AOT compilation)
- [ ] Macros
- [ ] Self-hosting compiler

## License

MIT
