# Design: Lisp Feature Gap Analysis

## Intent

Systematically compare SeqLisp against what a user familiar with Scheme/Common Lisp would expect, and identify:
1. **Feature gaps** -- missing primitives or constructs
2. **Test gaps** -- features that exist but lack test coverage

The goal is a prioritized punch list, not full Scheme compliance (the ROADMAP explicitly says "we cherry-pick features"). We want to make sure the features we *do* have are solid, and that obvious omissions have a conscious rationale.

## Constraints

- **Don't break what works.** No refactoring during the audit -- observation only.
- **Out of scope:** continuations, full numeric tower (rationals/complex), `call/cc`, hygienic macros, module system. These are already listed as non-goals.
- **No version bumps or releases** come out of this review.

---

## Pass 1 -- Feature Inventory

### Semantics (answered by code reading)

| Question | Answer |
|----------|--------|
| `let` bindings | **Single-binding only**: `(let name value body)`. No `(let ((a 1) (b 2)) ...)` form. |
| `define` scope | Top-level and inside `begin`. Function shorthand works. Named closures support self-recursion. |
| `lambda` rest args | Yes, dot notation: `(lambda (a b . rest) body)` |
| Currying | Automatic -- partial application and over-application both work |
| `if` arms | Two-arm only (no test for one-arm `(if cond then)` without else) |
| `cond` else | Yes, `else` keyword supported |
| `cond` `=>` syntax | No |
| Truthiness | **0 and #f are falsy**. Everything else is truthy -- including `'()` (empty list). This differs from Scheme where `'()` is truthy but `0` is also truthy. |
| TCO positions | `if` branches, `begin` last, `let` body, `cond` clauses, function bodies |
| Macros | Unhygienic `defmacro` with `gensym` for manual hygiene |
| `and`/`or` | Not builtins. `and2`/`or2` exist as test macros in defmacro.slisp but not in standard lib |
| `when`/`unless` | Same -- defined as test examples, not shipped in a standard lib |

### Feature Matrix

Legend: **Y** = present, **-** = missing, **N/A** = out of scope, **lib** = in lib/ but not stdlib

#### Arithmetic & Math

| Feature | Status | Notes |
|---------|--------|-------|
| `+` `-` `*` `/` | Y | Variadic `+`/`*`, binary `-`/`/` |
| `abs` `min` `max` `modulo` | Y | |
| `expt` / `pow` | - | Power function |
| `sqrt` | - | Square root |
| `floor` `ceiling` `round` `truncate` | - | Float→int conversions |
| `remainder` | - | Like modulo but sign follows dividend |

#### Comparison & Logic

| Feature | Status | Notes |
|---------|--------|-------|
| `<` `>` `<=` `>=` `=` | Y | Numeric only |
| `not` | Y | |
| `and` | - | Needs short-circuit special form or macro |
| `or` | - | Needs short-circuit special form or macro |
| `zero?` | - | Numeric predicate |
| `positive?` `negative?` | - | Numeric predicates |
| `even?` `odd?` | - | Numeric predicates |

#### Type Predicates

| Feature | Status | Notes |
|---------|--------|-------|
| `null?` `number?` `symbol?` `list?` `boolean?` | Y | |
| `integer?` `float?` `string?` | Y | |
| `equal?` | Y | Structural, depth-limited to 1000 |
| `pair?` | - | Non-empty list test (distinct from `list?` in Scheme) |
| `procedure?` / `closure?` | - | Test if value is callable |
| `char?` | N/A | No char type |

#### List Operations

| Feature | Status | Notes |
|---------|--------|-------|
| `cons` `car` `cdr` `list` | Y | |
| `append` `reverse` `length` | Y | |
| `nth` `last` `take` `drop` | Y | `nth` is 0-indexed |
| `map` `filter` `fold` `apply` | Y | |
| `assoc` | lib | In lib/lsp.slisp, not a builtin |
| `member` | - | Search for element in list |
| `for-each` | - | Like map but for side effects |
| `reduce` | - | fold without initial value (or alias) |
| `sort` | - | List sorting |
| `zip` | - | Combine two lists pairwise |
| `flatten` | - | Flatten nested lists |
| `list-ref` | - | Alias for `nth` (Scheme name) |
| `cadr` `caddr` etc. | - | Composition accessors |

#### String Operations

| Feature | Status | Notes |
|---------|--------|-------|
| 11 string ops | Y | length, substring, append, split, trim, up/downcase, contains?, starts-with?, find, chomp |
| `string->number` | - | Parse string to number |
| `number->string` | - | Number to string |
| `symbol->string` | - | Symbol name as string |
| `string->symbol` | - | Intern string as symbol |
| `string-ref` | - | Character at index (char-at exists in lsp lib) |
| `string-replace` | - | Find and replace |
| `string->list` / `list->string` | - | Conversion |
| `string-ends-with?` | - | Complement to starts-with? |

#### Control Flow & Binding

| Feature | Status | Notes |
|---------|--------|-------|
| `if` `cond` `begin` | Y | |
| `let` | Y | **Single-binding only** |
| `let*` | - | Sequential multi-binding |
| `letrec` | - | Recursive bindings |
| `set!` | - | Mutation |
| `when` `unless` | - | Easy as macros |
| `case` | - | Value dispatch |
| `do` | - | Iteration (could be macro over tail recursion) |
| `define` | Y | Top-level + function shorthand |
| `lambda` | Y | With rest params and currying |
| `defmacro` | Y | Unhygienic |
| `quote` / `'` | Y | |
| `quasiquote` / `` ` `` / `,` / `,@` | Y | |
| `try` | Y | Returns `(ok val)` or `(error msg)` |

#### Type Conversion

| Feature | Status | Notes |
|---------|--------|-------|
| `string->number` | - | |
| `number->string` | - | |
| `symbol->string` | - | |
| `string->symbol` | - | |
| `integer->float` | - | Explicit promotion |
| `float->integer` | - | Truncation / rounding |

#### I/O

| Feature | Status | Notes |
|---------|--------|-------|
| `print` `display` `write` | Y | |
| `read-line` `read-n` | Y | |
| `read-file` `write-file` `file-exists?` | Y | |
| `exit` | Y | |
| `newline` | - | Trivial (`(display "\n")`) |
| `error` (raise) | - | User-initiated error |
| Port-based I/O | N/A | Too complex for current scope |

#### Meta / Reflection

| Feature | Status | Notes |
|---------|--------|-------|
| `eval` | - | Not exposed (exists internally) |
| `load` | - | Load and evaluate file |
| `macroexpand` | - | Debug macro expansion |
| `gensym` | Y | |
| JSON parse/encode | Y | Bonus feature |

---

## Pass 3 -- Test Coverage Gaps

### Builtins with no error/edge tests

| Builtin | Has happy-path test | Missing error tests |
|---------|:-------------------:|---------------------|
| `+` `-` `*` | Y | Type errors (string + number), arity edge cases |
| `/` | Y | Division by zero (only tested in error_handling.slisp, not arithmetic.slisp) |
| `<` `>` `<=` `>=` `=` | Y | Type errors (comparing string to number) |
| `car` | Y | `(car '())` -- car of empty list |
| `cdr` | Y | `(cdr '())` -- cdr of empty list |
| `cons` | Y | Type error: non-list second arg |
| `nth` | Y | Out-of-bounds index |
| `last` | Y | `(last '())` -- last of empty list |
| `map` `filter` `fold` | Y | Non-function first arg, mismatched list lengths |
| `apply` | Y | Non-function, non-list args |
| `gensym` | Y | Wrong arity |
| `display` `print` | Minimal | Arity errors, various value types |
| `read-line` `read-n` | No | No tests at all (interactive I/O) |
| `json-parse` | Y | Malformed JSON input |
| `json-encode` | Y | Unencodable values |

### Features with no dedicated tests

- One-arm `if` (no else clause) -- unclear if it works
- `define` inside `let` body -- nested define behavior
- `defmacro` error cases -- bad macro definition syntax
- Variadic `append` -- `(append l1 l2 l3)` with 3+ lists
- Deeply nested `equal?` hitting the 1000-depth limit
- Currying edge cases -- over-application with wrong types
- `cond` with no matching clause and no `else` -- returns empty list (tested but worth noting)

---

## Prioritized Punch List

### Quick Wins (trivial, 1-2 hours each)

1. **`and` / `or` macros** -- already prototyped in defmacro tests, just need to ship in a standard prelude
2. **`when` / `unless` macros** -- same, already prototyped
3. **Numeric predicates**: `zero?`, `positive?`, `negative?`, `even?`, `odd?` -- simple dispatch additions
4. **`newline`** -- `(define (newline) (display "\n"))`
5. **`error` builtin** -- user-initiated error raise, e.g., `(error "bad input")`
6. **`procedure?`** -- test if value is a closure/macro
7. **`pair?`** -- test if value is a non-empty list

### Medium Effort (half day each)

8. **`let*`** -- sequential bindings, straightforward eval loop
9. **Type conversions**: `string->number`, `number->string`, `symbol->string`, `string->symbol`
10. **`assoc` / `member`** -- promote from lsp lib to builtins or standard prelude
11. **`case`** -- value-dispatch special form (or macro over `cond`)
12. **`for-each`** -- like `map` but discards results
13. **Math builtins**: `expt`, `sqrt`, `floor`, `ceiling`, `round`
14. **`string-replace`**, `string-ends-with?`
15. **Error test suite** -- add `assert-error` tests for type/arity errors across arithmetic, comparison, list ops

### Larger Effort (1+ day each)

16. **Multi-binding `let`** -- `(let ((a 1) (b 2)) body)` syntax; changes parsing of `let`
17. **`set!`** -- mutable bindings; philosophical decision about whether SeqLisp should have mutation
18. **`eval` / `load`** -- expose internal eval; `load` reads and evaluates a file
19. **Standard prelude file** -- auto-loaded library of macros/functions (`and`, `or`, `when`, `unless`, `case`, `compose`, etc.)
20. **`letrec`** -- recursive bindings; needs environment patching
