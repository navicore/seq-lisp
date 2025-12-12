# SeqLisp Architecture

## Overview

SeqLisp is a Lisp interpreter written in [Seq](https://github.com/navicore/patch-seq), a stack-based concatenative programming language. This document describes the architecture and key design decisions.

## Design Philosophy

**Lisp on a Stack Machine**: SeqLisp demonstrates that a tree-walking interpreter can be elegantly implemented in a concatenative language. The stack naturally handles intermediate values during evaluation, and Seq's quotations map well to Lisp's lambda expressions.

**Simplicity First**: The interpreter prioritizes clarity over optimization. Each component has a single responsibility, making the codebase approachable for learning both Lisp implementation and Seq programming.

## Components

```
┌─────────────────────────────────────────────────────────┐
│                        REPL                              │
│                      (repl.seq)                          │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      Evaluator                           │
│                      (eval.seq)                          │
│  - Environment management                                │
│  - Special forms (if, let, lambda, define)              │
│  - Primitive operations (+, -, *, /, comparisons)       │
│  - Closure creation and application                      │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                       Parser                             │
│                     (parser.seq)                         │
│  - Token stream → S-expression tree                      │
│  - Recursive descent for nested lists                    │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      Tokenizer                           │
│                    (tokenizer.seq)                       │
│  - Character stream → token list                         │
│  - Handles: parens, numbers, symbols                     │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   S-Expression Types                     │
│                     (sexpr.seq)                          │
│  - Variant types: snum, ssym, slist, snil               │
│  - Constructors and accessors                            │
│  - Pretty printing                                       │
└─────────────────────────────────────────────────────────┘
```

## Data Structures

### S-Expressions

S-expressions are represented as Seq variants (tagged unions):

| Type    | Tag | Description                    |
|---------|-----|--------------------------------|
| `snum`  | 1   | Integer literal                |
| `ssym`  | 2   | Symbol (identifier)            |
| `slist` | 3   | Cons cell (car, cdr pair)      |
| `snil`  | 4   | Empty list / nil               |

### Environments

Environments are association lists mapping symbol names to values:

```
env = snil                           # Empty environment
env = scons(pair, parent_env)        # Extended environment
pair = scons(name_sym, value)        # Name-value binding
```

Lookup traverses the chain, enabling lexical scoping.

### Closures

Closures capture their definition environment:

```
closure = variant with tag "closure"
  - params: list of parameter symbols
  - body: s-expression to evaluate
  - env: captured environment
```

## Evaluation Model

The evaluator is a tree-walker that pattern-matches on S-expression types:

1. **Numbers**: Return as-is (self-evaluating)
2. **Symbols**: Look up in environment
3. **Lists**: Check if car is special form or function:
   - Special forms: `if`, `let`, `lambda`, `define`
   - Otherwise: evaluate car (must be closure), evaluate args, apply

### Special Forms

| Form | Syntax | Semantics |
|------|--------|-----------|
| `if` | `(if cond then else)` | Evaluate cond; if non-zero, eval then, else eval else |
| `let` | `(let name value body)` | Bind name=value, evaluate body in extended env |
| `lambda` | `(lambda (params) body)` | Create closure capturing current environment |
| `define` | `(define name value)` | Bind name globally (at top level) |

## Key Design Decisions

### Why Variants for S-Expressions?

Seq's variant system provides:
- Type-safe tagged unions
- Pattern matching via tag checks
- Efficient field access

This maps directly to Lisp's cons cells and atoms.

### Why Association Lists for Environments?

- Simple to implement in a stack language
- Natural representation of scope chains
- Easy to extend (just cons a new binding)
- Lookup is O(n) but environments are typically small

### Stack-Based Expression Evaluation

The Seq stack naturally handles:
- Intermediate values during nested evaluation
- Multiple return values (though Lisp uses single values)
- Argument passing to primitives

Example: Evaluating `(+ 1 (* 2 3))`
```
Stack operations:
  eval (+ 1 (* 2 3))
    → eval +        → primitive
    → eval 1        → 1 on stack
    → eval (* 2 3)
      → eval *      → primitive
      → eval 2      → 2 on stack
      → eval 3      → 3 on stack
      → apply *     → 6 on stack
    → apply +       → 7 on stack
```

## File Organization

```
src/
├── tokenizer.seq   # Lexical analysis
├── parser.seq      # Builds S-expression trees
├── sexpr.seq       # S-expression data types
├── eval.seq        # Evaluator + environments
├── repl.seq        # Interactive loop
└── test_*.seq      # Component tests
```

Tests live alongside source because Seq's include system resolves paths relative to the including file.

## Error Handling

SeqLisp uses a comprehensive `EvalResult` union type for error handling:

```seq
union EvalResult {
  EvalOk { value: Sexpr }       # Successful evaluation
  EvalErr { message: String }   # Error with message
  EvalDefine { name: String, def_value: Sexpr }  # Definition result
}
```

All `eval-*-with-env` functions return `EvalResult`, enabling:
- **Error propagation**: Errors bubble up through nested expressions
- **Graceful REPL recovery**: REPL continues after errors
- **Consistent error messages**: All errors use the same format

### Error Categories

| Category | Example | Message |
|----------|---------|---------|
| Arity | `(car 1 2)` | `car expects 1 argument(s)` |
| Type | `(car 42)` | `car: argument must be a list` |
| Undefined | `(foo)` | `undefined symbol: foo` |
| Division | `(/ 1 0)` | `division by zero` |

### Future Improvements

- Source location tracking through tokenizer/parser/evaluator
- Stack traces showing call chain
- "Did you mean X?" suggestions for undefined symbols
