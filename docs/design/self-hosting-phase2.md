# Self-Hosting Phase 2: Fix Before Extend

Follows the completed [self-hosting.md](self-hosting.md) (phases 1-4).

## Intent

Phase 4 shipped a working self-hosted evaluator but left two problems:

1. **Duplicate implementations.** `map`, `filter`, `fold`, `apply`, `not`
   exist in both the self-hosted bootstrap AND the host eval. Two
   implementations of the same function is a maintenance and correctness
   hazard. Each self-hosted function should replace its host equivalent,
   not coexist with it.

2. **Missing TCO.** The self-hosted eval uses plain recursion. Programs
   that rely on tail-call optimization (a core language feature) will
   stack overflow under `seval-string`/`sload`. This is a regression
   from the design constraint "don't break existing programs."

No new builtins should be moved into self-hosting until these are resolved.

## Constraints

- **Don't break existing programs or the host test suite.** The 496
  host-eval tests must continue to pass.
- **Single implementation.** When a function is self-hosted, the host
  version is removed. Not "both exist."
- **TCO before expansion.** No new bootstrap functions until the
  self-hosted eval can handle deep tail recursion.

## Approach

### Step 1 — TCO via trampoline

Add tail-call optimization to the self-hosted eval. When `self-eval`
is in a tail position (last expression of `if`, `cond`, `begin`, `let`,
function body), return a thunk `(__thunk__ env expr)` instead of
recursing. A top-level trampoline loop evaluates thunks until a final
value is reached.

Checkpoint: `(seval-string "(define (sum n acc) (if (= n 0) acc (sum (- n 1) (+ acc n)))) (sum 10000 0)")` returns `50005000`.

### Step 2 — Deduplicate: remove host versions of self-hosted functions

For `map`, `filter`, `fold`, `apply`, `not`: remove the host
implementations from eval.seq dispatch and redirect them to the
self-hosted versions. The host eval should call through to the
self-hosted bootstrap for these functions.

At host startup, evaluate a bootstrap `.slisp` file through the host's
own parse + eval. The resulting closures go into the global environment.
Remove `map`, `filter`, `fold`, `not` from the host dispatch chain.
User code finds the SeqLisp closures via normal environment lookup.

The host's internal `apply` (used by the eval machinery for function
application) stays in Seq but is renamed to `__host-apply__` — an
ugly internal name that is obviously not part of the language. The
user-facing `apply` is the self-hosted version in the bootstrap.

Checkpoint: host test suite passes with `map`/`filter`/`fold`/`not`
removed from eval.seq dispatch. No duplicate implementations.

### Step 3 — Then expand

Only after steps 1-2: move more functions into the bootstrap, add
`try` as a special form, build the self-hosted REPL.

## Open Questions

- Should the bootstrap source move from a string literal in `eval.slisp`
  to a separate `.slisp` file loaded at init?
- Which host-internal functions besides `apply` need ugly-renaming to
  distinguish them from user-facing self-hosted versions?
