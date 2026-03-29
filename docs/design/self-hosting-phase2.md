# Self-Hosting Phase 2: Fix Before Extend

Follows the completed [self-hosting.md](self-hosting.md) (phases 1-4).

## Completed

### Step 1 — TCO via trampoline (PR #69)

Tail positions return `(__thunk__ env expr)` instead of recursing.
A trampoline loop drives evaluation. Covers: `if`, `cond`, `begin`,
`let`, closure body, macro expansion. `(sum 10000 0)` works.

**Regression: mutual recursion doesn't work** in the self-hosted eval.
The host eval handles this via mutable environments; the self-hosted
eval uses immutable envs where the first-defined function can't see
the second. Fixing this requires either mutable env cells or a
`letrec`-style form. This should be addressed before the self-hosted
eval is considered production-ready.

### Step 2 — Deduplicate bootstrap functions (PR #70)

Attempted to self-host `map`, `filter`, `fold`, `not`. Reverted
`map`/`filter`/`fold` to native — self-hosted closures consume too
much host stack per call, causing stack overflow on ~5,000+ element
lists. This is a fundamental limitation of evaluating closures through
the host's tree-walking eval.

Current state: only `not` is self-hosted (no recursion, no stack risk).
`map`, `filter`, `fold`, `apply` stay native.

Self-hosting recursive higher-order functions requires either:
- First-class builtins (so self-hosted functions can call `+` etc.
  without going through the host eval's closure application path)
- A fundamentally different execution model (compilation, bytecode)

## Regressions — Must Fix Before Next Release

### 1. `map`/`filter` stack overflow on large lists

The self-hosted `map` and `filter` (SeqLisp closures evaluated by the
host) consume far more stack per recursive call than the native Seq
implementations they replaced. `map` and `filter` on ~10,000-element
lists crash with stack overflow. This affects **all users** via the
host eval, not just the self-hosted eval.

`fold` is tail-recursive and works via the host's TCO — not affected.

Confirmed: `(map (lambda (x) (+ x 1)) (range 1000 '()))` works.
`(map (lambda (x) (+ x 1)) (range 10000 '()))` crashes (exit 132).

Options:
- **A.** Rewrite `map`/`filter` as iterative using `fold` + `reverse`
  (eliminates the recursion, uses tail-recursive `fold`)
- **B.** Revert to native Seq `map`/`filter` until the stack depth
  issue is resolved (abandons single-implementation goal temporarily)
- **C.** Increase the host stack size (bandaid, doesn't fix the root cause)

Option A is preferred — it preserves self-hosting and fixes the issue.

### 2. Mutual recursion broken in self-hosted eval

The self-hosted eval uses immutable environments. When `even?` is
defined, `odd?` isn't in the env yet. The host eval handles this with
mutable environments. No host test suite coverage exists for mutual
recursion — the gap went undetected.

This affects code run through `seval-string`/`sload` only, not the
host eval. But it means the self-hosted eval cannot run a meaningful
subset of valid SeqLisp programs.

Options:
- **A.** Add `letrec` to the self-hosted eval that pre-binds all names
  before evaluating any bodies
- **B.** Make `do-eval-all` do a two-pass define: first pass creates
  placeholder closures with the final env, second pass fills them in

Both regressions need test coverage added to prevent future recurrence.

## Remaining Work

### Expand the bootstrap stdlib (limited)

Only non-recursive functions can be self-hosted in the host eval's
bootstrap. Self-hosted closures consume too much host stack per call
for recursive functions on large inputs.

In Lisp, almost all interesting functions are recursive. The viable
candidates for self-hosting in the bootstrap are trivial compositions:
- **Predicates**: `>=`, `<=`, `zero?`, `positive?`, `negative?`
- **Arithmetic**: `abs`, `min`, `max`
- **List accessors**: `cadr`, `caddr` (fixed car/cdr chains)

All recursive functions (`map`, `filter`, `fold`, `append`, `reverse`,
`length`, `nth`, `take`, `drop`, `equal?`) must stay native.

Deeper self-hosting of recursive functions requires either first-class
builtins (so closures can call `+` without host eval overhead) or a
different execution model (compilation to Seq, bytecode interpreter).

### Self-hosted `try`

Currently not a special form in the self-hosted eval. Needed for
the self-hosted REPL to recover from errors gracefully. Requires
defining how the self-hosted eval's error representation interacts
with `try`'s `(ok value)` / `(error message)` contract.

### Self-hosted REPL

A read-eval-print loop in SeqLisp: read from stdin via `read-line`,
tokenize, parse, evaluate with `self-eval`, print result, loop.
Must thread environment across inputs so defines persist.

Depends on: `try` (for error recovery), and the eval being robust
enough for interactive use.

### Resolve bootstrap source duplication

The bootstrap source exists in two places:
- Embedded string in `src/eval.seq` (canonical, what actually runs)
- `lib/bootstrap.slisp` (reference copy, not loaded)

Options:
1. Build step that generates the embedded string from the `.slisp` file
2. CI check that verifies they match
3. Delete the reference copy entirely

Option 1 is cleanest.

## Constraints

- **Don't break existing programs or tests.**
- **Single implementation.** When a function is self-hosted, the host
  version is removed.
- **`apply` stays native.** Documented exception — builtins aren't
  first-class values.
- **Performance is secondary to correctness.** The serialization
  round-trip for host builtins is a known cost.
