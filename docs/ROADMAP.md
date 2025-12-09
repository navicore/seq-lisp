# SeqLisp Roadmap

## Vision

SeqLisp explores the intersection of two programming paradigms:
- **Lisp**: The programmable programming language, with its elegant homoiconicity
- **Seq**: A modern stack-based concatenative language with static typing

The goal is not just to implement Lisp, but to discover what happens when these paradigms meet.

## Current Status (v0.1)

A working interpreter with:

- [x] Tokenizer and parser
- [x] S-expression data types (numbers, symbols, lists)
- [x] Environment-based evaluation
- [x] Arithmetic operations (+, -, *, /)
- [x] Comparisons (<, >, <=, >=, =)
- [x] Conditionals (if)
- [x] Let bindings
- [x] Lambda and closures
- [x] Interactive REPL
- [x] Test suite
- [x] CI/CD
- [x] ADT unions for type-safe data structures (Sexpr, SexprList, Env, Binding, LispClosure)

## Short Term

### Better REPL Experience
- [ ] Multi-line input support
- [ ] Error recovery (don't crash on bad input)
- [ ] Command history (if Seq gets readline support)

### Core Lisp Features
- [x] `quote` and `'` syntax
- [x] List operations: `cons`, `car`, `cdr`, `list`
- [x] Predicates: `null?`, `number?`, `symbol?`, `list?`
- [x] Boolean literals: `#t`, `#f`
- [x] `begin` for sequencing
- [ ] `cond` as multi-way conditional

### Code Quality
- [ ] Refactor to use `EvalResult` union type instead of magic tag numbers
  - Create `union EvalResult { Value { result: Sexpr }, Definition { name: String, value: Sexpr } }`
  - All `eval-*-with-env` functions return `EvalResult`
  - REPL matches on `EvalResult` variants instead of checking tag 70
  - Enables proper type safety and idiomatic Seq ADT usage
- [ ] Refactor builtin dispatch to reduce nesting
  - Current dispatch uses 18+ levels of nested if-else
  - Consider lookup table or function pointer approach
  - Improves maintainability as more builtins are added

### Error Handling
- [ ] Graceful error messages with context
- [ ] Source location tracking through evaluation
- [ ] REPL continues after errors

## Medium Term

### Standard Library
- [ ] List utilities: `map`, `filter`, `fold`, `append`, `reverse`
- [ ] Higher-order functions: `apply`, `compose`
- [ ] Numeric: `abs`, `min`, `max`, `modulo`
- [ ] String operations (when Seq strings are richer)

### Language Features
- [ ] `define` at top-level for global definitions
- [ ] Variadic functions
- [ ] Optional/rest parameters
- [ ] Tail call optimization (important for idiomatic Lisp)

### Macros
- [ ] `defmacro` for syntactic abstraction
- [ ] Quasiquote (`` ` ``), unquote (`,`), splice (`,@`)
- [ ] Macro expansion phase

## Long Term

### The Compiler Question

The classic Lisp dilemma: interpreter vs compiler?

**Option A: Pure Interpreter**
- Keep `eval` for runtime flexibility
- REPL remains fully dynamic
- Simpler implementation

**Option B: Lisp-to-Seq Compiler**
- Compile Lisp source to Seq source
- Leverage Seq's type system and optimizations
- Could coexist with interpreter for REPL

**Option C: Hybrid**
- Compile "cold" code paths
- Interpret "hot" code (macros, eval)
- Best of both worlds, most complex

Current thinking: Start with interpreter, add compilation as an optimization for known-good code.

### Type System Integration

Seq has a static type system with stack effects. Could we:
- Infer types for Lisp functions?
- Generate typed Seq code?
- Catch errors at compile time?

This is research territory - traditional Lisp is dynamically typed.

### Interoperability

- Call Seq builtins from Lisp
- Call Lisp functions from Seq
- Share data structures

### Self-Hosting

The ultimate test: implement enough of SeqLisp to write SeqLisp in itself.

## Non-Goals

Things we're explicitly not trying to do:

- **Full Scheme/CL compatibility**: We cherry-pick features
- **Performance parity with C**: Educational clarity over speed
- **Complex numeric tower**: Integers are enough for now
- **Continuations**: Seq's execution model doesn't support them easily

## Contributing

Ideas and contributions welcome! Areas where help is especially appreciated:

1. **More Lisp examples** in `examples/`
2. **Test cases** for edge cases
3. **Documentation** improvements
4. **List operations** implementation
5. **Error handling** improvements

## Versioning

We'll use semantic versioning once we reach 1.0:
- **0.x**: Experimental, breaking changes expected
- **1.0**: Stable core language
- **1.x**: Backward-compatible additions
