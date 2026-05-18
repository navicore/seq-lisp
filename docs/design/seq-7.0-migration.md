# Seq 7.x migration

Status: design · 2026-05-17

## Intent

The installed `seqc` is 7.4.0 (we last migrated against 6.x — see
`seq-6.0-if-combinator-migration.md`). The build currently fails at
`src/repl.seq:290` with `Undefined word 'io.read-line+'`. Get seqlisp
building and green again under 7.4.0 by applying the (small) subset of
`../patch-seq/MIGRATION_7_0.md` rules that actually touch our source,
plus the post-7.0 cleanup that removed `io.read-line+`.

## Constraints

- **Behavior must not change.** All Seq tests in `tests/seq/**` and all
  Lisp tests in `tests/lisp/**` must pass after migration. The TCO
  guarantee from `ARCHITECTURE.md` (10k+ depth) must still hold.
- **No drive-by refactors.** Don't restructure `eval.seq`, don't split
  files toward the ~200-line guideline, don't rework the dispatch chain.
  Same discipline as the 6.0 pass.
- **No `tests/` edits unless a test file itself calls a removed
  builtin.** A grep of `tests/seq/*.seq` finds none, so tests should
  not move.
- **Out of scope:** all 7.0 rules that don't apply to our source (see
  Approach for the survey). Specifically: stdlib `pow`/`mod` removal,
  TCP/UDP/HTTP networking rename and `Socket` nominal type, multi-char
  ad-hoc type variable error, new float math builtins. We don't use
  any of these. Also out of scope: the `MIGRATION_5.0.md`/`5.5.md`
  rules — we already shipped past them.

## Approach

**Survey of 7.0 rules against our source:**

| Rule | Subject | Our usage | Action |
|---|---|---|---|
| 1 | `mod` removed → `i.modulo` | None. `vim-line.seq` defines a local `int-mod` helper unrelated to stdlib `mod`. | None |
| 2 | New `f.sqrt` / `f.sin` / `f.pi` / … builtins | Additive | None |
| 3 | TCP/UDP fds typed as `Socket` | We don't use networking | None |
| 4 | Multi-char ad-hoc type vars are an error | All multi-char names in our stack effects are registered `union`s (Sexpr, Env, EvalResult, Token, etc. — checked) | None |
| 5 | `tcp.*` / `udp.*` / `http.*` → `net.*` | We don't use networking | None |
| 6 | `pow` removed → `i.pow` (now returns `Bool`) | None | None |

**Post-7.0 cleanup (not in `MIGRATION_7_0.md` but in patch-seq commit
`0fc3a8b`): `io.read-line+` removed.** Successor `io.read-line` exists
with a different signature and inverted success semantics:

| | Old `io.read-line+` | New `io.read-line` |
|---|---|---|
| Effect | `( -- String Int )` | `( -- String Bool )` |
| EOF | `Int = 0` | `Bool = false` |
| Got line | `Int ≠ 0` | `Bool = true` |

Two call sites, both follow the pattern
`io.read-line+ 0 i.= [ EOF... ] [ got-line... ] if`:

- `src/repl.seq:290` in `read-all-stdin`
- `src/eval.seq:2006` in `(read-line)` Lisp builtin

Migration per site: drop `0 i.=` and **swap the branches**, so the
true (got-line) branch comes first per the `if` combinator's
`( Bool [then] [else] -- )` order. Update the two adjacent comments
that name `io.read-line+`.

**Why swap rather than `not`:** `not` would keep the source order but
add a noisy unary on the bool — branch swap is one local edit per
site, matches the spec's recommendation for the combinator, and lines
the two sites up with the form readers expect (`if` → success-first).

**Execution order:** fix the two sites, run `just build`, then `just
ci`. If a second-wave error surfaces from a 7.x change we didn't
anticipate, capture it here as an addendum before extending scope —
don't expand the patch silently.

## Domain Events

- **Produces:** a source tree that builds and tests green under `seqc
  7.4.0`. No public-facing surface change — Lisp-level `read-line`
  still returns the string or `#f` on EOF; the rename happens entirely
  beneath the Seq/Lisp boundary.
- **Consumes:** `../patch-seq/MIGRATION_7_0.md` (no applicable rules
  found this pass) and patch-seq commit `0fc3a8b` for the
  `io.read-line+` removal.
- **Must follow:** README/CHANGELOG note bumping the minimum supported
  `seqc` to 7.0+ (git is the user's job; not part of this change).

## Checkpoints

1. `just build` succeeds (currently fails on `io.read-line+`).
2. `just test` — Seq unit tests pass.
3. `just ci` — full suite (Seq + Lisp + LSP) passes.
4. Smoke: `echo '(read-line)' | ./target/seqlisp` returns `#f` on
   empty stdin; `printf 'hello\n' | ./target/seqlisp -e '(read-line)'`
   (or equivalent) returns `"hello"`. Confirms branch swap got
   EOF / got-line right at both sites.
5. Spot-check: 10k-depth tail-recursion smoke from
   `ARCHITECTURE.md` still completes — confirms nothing in the
   `if`-combinator lowering regressed across the 7.x bump.
