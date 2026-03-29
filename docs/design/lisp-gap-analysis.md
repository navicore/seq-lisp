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

## Approach

Audit in three passes, each producing a checklist:

### Pass 1 -- Core Language Primitives

Compare the builtin dispatch groups against the R5RS / Scheme essential procedures:

| Category | Have | Likely Missing |
|----------|------|----------------|
| Arithmetic | `+ - * / abs min max modulo` | `floor`, `ceiling`, `round`, `truncate`, `remainder`, `expt`/`pow`, `sqrt` |
| Comparison | `< > <= >= =` | `zero?`, `positive?`, `negative?`, `even?`, `odd?` (numeric predicates) |
| Logical | `not`, `#t`/`#f` | `and`/`or` as special forms (short-circuit) -- may exist as macros? |
| List | `cons car cdr list append reverse length nth last take drop` | `assoc`, `member`, `for-each`, `list-ref` (alias for nth?), `pair?`, `list->string` |
| Higher-order | `map filter fold apply` | `reduce` (alias?), `for-each`, `sort` |
| String | 11 string ops | `string->number`, `number->string`, `string->symbol`, `symbol->string`, `string-ref`, `string->list`, `string-replace` |
| Type conversion | -- | `number->string`, `string->number`, `char->integer`, `integer->char` |
| I/O | `print display write read-line read-n read-file write-file file-exists?` | `newline`, `open-input-file`/ports (probably out of scope) |
| Control | `begin cond if try` | `when`, `unless`, `case`, `do` (could be macros) |
| Binding | `let define lambda` | `let*`, `letrec`, `set!`, `define-values` |
| Misc | `gensym equal?` | `void`, `error` (explicit raise), `eval`, `load` |

### Pass 2 -- Special Forms & Semantics

Check behavioral correctness of what exists:
- `let` -- does it support multiple bindings `(let ((a 1) (b 2)) ...)`? Or is it single-binding only?
- `define` -- mutual recursion? Top-level only or nested?
- `lambda` -- rest args work? Closures over mutable bindings?
- `if` -- two-arm and one-arm (no else)?
- `cond` -- `else` clause? `=>` syntax?
- Truthiness -- is everything except `#f` truthy? Or is `0`/`nil`/`'()` falsy?
- Tail position -- `let` body, `cond` clauses, `when`/`unless` body

### Pass 3 -- Test Coverage

For each feature that exists, verify there's at least one test. Flag:
- Builtins with zero tests
- Edge cases: empty list, wrong types, arity errors
- Error messages: are they tested via `assert-error`?

## Checkpoints

1. **Pass 1 complete:** Markdown table of every expected primitive, marked as present / missing / not-applicable, with notes.
2. **Pass 2 complete:** List of semantic questions answered by reading code or running expressions.
3. **Pass 3 complete:** Test coverage matrix -- feature vs test file, with gaps highlighted.
4. **Final deliverable:** A single prioritized issue list (could become GitHub issues) categorized as:
   - **Quick wins** -- trivial to add (numeric predicates, aliases)
   - **Medium effort** -- `let*`, `set!`, `case`, type conversions
   - **Large / deferred** -- anything touching the evaluator loop deeply
