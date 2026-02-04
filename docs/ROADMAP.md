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
- [x] Seq 4.0 migration - compile-time type safety via auto-generated predicates/accessors

## Short Term

### Better REPL Experience ✓
- [x] Multi-line input support (paren balancing)
- [x] Continuation prompt (...) for incomplete expressions
- [x] Environment persists across expressions
- [x] Error recovery (REPL continues after errors)
- [x] Command history with persistence (via libedit FFI, saved to ~/.seqlisp_history)

### Core Lisp Features
- [x] `quote` and `'` syntax
- [x] List operations: `cons`, `car`, `cdr`, `list`
- [x] Predicates: `null?`, `number?`, `symbol?`, `list?`, `boolean?`, `equal?`
- [x] Boolean literals: `#t`, `#f`
- [x] `begin` for sequencing
- [x] `cond` as multi-way conditional

### Code Quality ✓
- [x] Refactor builtin dispatch to reduce nesting
  - Replaced 25+ levels of nested if-else with grouped dispatch chain
  - 8 logical groups: arithmetic, comparison, special forms, list ops, predicates, control flow, I/O, user-defined
  - Each group handles 2-5 builtins, max nesting depth of 5
  - Easy to extend: add new builtins to their logical group

### Error Handling

The current architecture is sound for adding comprehensive error handling. No fundamental redesign is needed.

**What works well:**
- Clean evaluation entry point (`eval-with-env` is the single dispatch point)
- ADT-based types (`Sexpr`, `Env`, `Binding`, `LispClosure` are proper union types)
- Environment is threaded through evaluation, so errors can propagate up the call stack

**Phase 1: Basic Recovery (Short Term)** ✓
- [x] REPL continues after errors (catch crashes, continue session)
- [x] Basic arity validation for builtins (wrong arg count → error message)
- [x] Graceful error messages instead of crashes
- [x] Error propagation through nested expressions

**Phase 2: Full Error Handling (Medium Term)** ✓
- [x] `EvalResult` union type for error propagation
  ```seq
  union EvalResult {
    EvalOk { value: Sexpr }
    EvalErr { message: String, span: SourceSpan }
    EvalDefine { name: String, def_value: Sexpr }
  }
  ```
- [x] Update all `eval-*-with-env` functions to return `EvalResult`
- [x] Type validation for builtins (e.g., `car` requires a list, `cons` requires list as second arg)
- [x] Undefined symbol errors with suggestions
  - Searches both builtins and user-defined symbols in scope
  - Uses prefix-matching heuristic (first 3 chars) with length penalty
  - Example: `lamda` suggests `lambda`, `my-functon` suggests `my-function`

**Phase 3: Rich Diagnostics (Long Term)**
- [x] Source location tracking through tokenizer/parser/evaluator
  - SourceSpan type with start/end line/column
  - Tokenizer tracks positions for all tokens
  - Parser propagates spans to S-expressions
  - Evaluator includes spans in EvalErr for LSP diagnostics
- [x] Error messages display line/column information
  - Format: `Error [line:col]: message` when span is available
  - Falls back to `Error: message` when no span
  - File mode shows correct multi-line positions
- [x] Stack traces showing call chain
  - CallStack type tracks function call frames
  - Errors include full stack trace with function names and locations
  - Format: `Error [line:col]: message` followed by `  at funcname (line:col)` entries
- [ ] Error recovery suggestions

## Medium Term

### Standard Library
- [x] List utilities: `append`, `reverse`
- [x] List utilities: `map`, `filter`, `fold`
- [x] List utilities: `length`, `nth`, `last`, `take`, `drop`
- [x] `compose` - implemented as macro (see examples/macros.slisp)
- [x] Higher-order functions: `apply`
- [x] Numeric: `abs`, `min`, `max`, `modulo`
- [x] String operations - Lisp wrappers for Seq builtins (40 tests in `tests/lisp/core/strings.slisp`)
  - `string-length`, `substring`, `string-append` (already existed)
  - `string-split`, `string-trim`, `string-upcase`, `string-downcase`
  - `string-contains?`, `string-starts-with?`, `string-find`, `string-chomp`

### Language Features
- [x] `define` at top-level for global definitions
  - Simple binding: `(define name value)`
  - Function shorthand: `(define (name params...) body)`
- [x] Currying and partial application
  - Automatic currying for multi-parameter lambdas
  - Over-application passes extra args to returned closures
- [x] Variadic macros with rest parameters
  - Dot notation: `(defmacro (name . args) body)` or `(defmacro (name req . rest) body)`
  - Enables natural `(and a b c)` style macros instead of `(and-list (a b c))`
- [x] Variadic functions (lambdas with `. rest` syntax)
- [x] Tail call optimization (TCO)
  - Leverages Seq's native TCO by ensuring tail calls are in true tail position
  - Enables deep recursion (tested to 10000+ depth) without stack overflow
  - Works for `if`/`cond` branches, `begin` last expression, `let` body, and function bodies

### Macros ✓
- [x] `defmacro` for syntactic abstraction
- [x] Quasiquote (`` ` ``), unquote (`,`), splice (`,@`)
- [x] Macro expansion phase (lazy expansion at call site)
- [x] `gensym` for unique symbol generation
- [x] Variadic macros with dot notation (`. rest`)

### Test Framework ✓
- [x] Assertion-based test runner (in `lib/test.slisp`)
  - `assert-eq` for value comparison using structural equality
  - `assert-true` / `assert-false` for boolean checks
  - `assert-error` for expected error conditions
  - Pass/fail counters with summary output
  - Non-zero exit code on failure (exit 1 on any failure, exit 0 on all pass)
  - `run-suite` macro for organizing tests
- [x] New builtins to support testing:
  - `equal?` - structural equality comparison
  - `exit` - process exit with code for CI/CD
  - `try` - error handling (returns `(ok value)` or `(error message)`)
- [x] CI integration with clear pass/fail reporting
  - `just ci` runs full test suite (Seq tests, Lisp tests, LSP tests)
  - Non-zero exit on any failure
- [ ] Future enhancements:
  - Reorganize test suites by feature

### Tooling

**LSP (Language Server Protocol)** - Partial
- [x] Basic LSP server (written in SeqLisp itself)
- [x] `textDocument/didOpen` and `textDocument/didChange`
- [x] `textDocument/completion` for builtins and keywords
- [x] Diagnostics (parse errors, undefined symbols) via `textDocument/publishDiagnostics`
- [ ] Hover (builtin docs, function info)
- [ ] Go to Definition
- [ ] Document Symbols

**Code Formatter**
- [ ] Consistent indentation based on nesting
- [ ] Preserve comments

### Vim-Style REPL Editor ✓ ([#52](https://github.com/navicore/seq-lisp/issues/52))

Replaced libedit with a vim-style line editor written in pure Seq (`src/vim-line.seq`), using the terminal FFI:

**Phase 1: Basic Modal Editing** ✓
- [x] Normal/Insert modes with `i`, `a`, `I`, `A`, `Escape`
- [x] Basic cursor movement (`h`, `l`, `0`, `$`, `%` for bracket matching)
- [x] Backspace, delete (`x`), replace (`r`), Enter to submit

**Phase 2: Vim Motions** ✓
- [x] Word motions (`w`, `b`)
- [ ] Character find (`f`, `F`, `t`, `T`) - not yet implemented

**Phase 3: Operators** ✓
- [x] Delete/change with motion (`d`, `c` + `d`, `w`, `$`)
- [x] Yank and paste (`y`, `p`, `P`)
- [x] `D`, `C` for delete/change to end of line

**Phase 4: Polish** ✓
- [x] Command history with `j`/`k` and arrow keys
- [x] Undo with `u`
- [ ] Visual mode - not yet implemented

### Seq Code Quality ([#51](https://github.com/navicore/seq-lisp/issues/51))

- [ ] Convert `while`/`until`/`times` usage to recursive style
  - These combinators require neutral stack effects, creating false expectations
  - Use recursion or fold/map/filter instead
  - Gather data on what patterns emerge to inform Seq language design

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

### Self-Hosted Tools (macros now available)
- [ ] Linter written in SeqLisp
  - Analyze code as data (homoiconicity)
  - User-extensible lint rules
  - Pattern matching on S-expressions

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
