# Seq 6.0 `if`-combinator migration

Status: design · 2026-04-27

## Intent

Seq 6.0 removes `if`/`else`/`then` as parser keywords and replaces them with
the stack-consuming `if` combinator and its `when` / `unless` variants
(see `../patch-seq/docs/MIGRATION_6_0.md`). The installed `seqc 6.1.0`
already rejects our source — the build currently fails at `src/repl.seq:39`.
Migrate every `.seq` file in this repo to the combinator form so the project
builds again. Adopting the combinator form also makes branching consistent
with the rest of Seq's quotation-based control flow.

## Constraints

- **Behavior must not change.** The interpreter's externally-observable
  semantics (every Lisp test in `tests/lisp/**` and every Seq test in
  `tests/seq/**`) must pass after migration. The migration is purely
  syntactic.
- **No accidental refactors.** Per the migration spec the rewrite is local
  and deterministic — preserve order, indentation, comments, and nested
  constructs verbatim. Don't combine, reorder, or "clean up" branches while
  migrating.
- **TCO must be preserved.** Self-tail-calls inside branches still get
  `musttail` lowering under the combinator form (verified by patch-seq).
  The TCO behavior described in `ARCHITECTURE.md` (depth 10k+) must still
  hold post-migration.
- **No version bumps, no test edits.** Tests stay as-is unless they
  themselves contain `if/else/then` Seq code (a few do — `tests/seq/`).
- **Out of scope:** any other 6.0 changes, restructuring `eval.seq`,
  splitting files for the ~200-line guideline, refactoring the dispatch
  chain. Pure keyword→combinator rewrite only.

## Approach

Apply the spec's two transformation rules mechanically, file by file:

- Rule 1 (two-armed): `cond if A else B then` → `cond [ A ] [ B ] if`
- Rule 2 (one-armed): `cond if A then` → `cond [ A ] when`
- Inside-out for nested cases. No `>aux`/`aux>` usage exists in our source
  (verified), so the edge case in §"When `when`/`unless` aren't enough" of
  the spec doesn't apply. Divergent (recursive non-returning) branches in
  the eval/REPL loop will use `cond [ A ] [ ] if` per the spec's caveat.

Scope (counted by `then` keyword occurrences):

| File | Conditionals |
|---|---|
| `src/eval.seq` | 494 |
| `src/vim-line.seq` | 61 |
| `src/tokenizer.seq` | 30 |
| `src/repl.seq` | 28 |
| `src/parser.seq` | 23 |
| `src/json.seq` | 16 |
| `src/sexpr.seq` | 1 |
| `tests/seq/*` | 3 |
| **Total** | **~656** |

Strategy: hand-migrate smallest files first (`sexpr.seq`, `json.seq`,
`parser.seq`, `tokenizer.seq`, `repl.seq`, test files, `vim-line.seq`),
verifying each with `seqc build` before moving on. Save `eval.seq` for last
and migrate it function-by-function — each `: ... ;` definition is an
independent, type-checkable unit. The typechecker is the safety net per the
spec; a clean `seqc build` plus passing test suite proves the rewrite.

Don't try to write a sed/awk script — the rules are local but require
matching nested `if`/`else`/`then` triples, and the cost of a malformed
auto-rewrite (silent semantic change inside one of 494 conditionals) is
higher than the cost of careful manual migration. Use editor multi-cursor
on trivially-shaped one-liners (e.g. the four `if "#t" else "#f" then`
sites already grepped in `eval.seq`) where it's safe.

## Domain Events

- **Produces:** a fully migrated source tree that builds under `seqc 6.1.0`.
- **Consumes:** the migration spec at `../patch-seq/docs/MIGRATION_6_0.md`.
- **Must follow:** README/CHANGELOG note that the minimum supported `seqc`
  is now 6.0+ (handled by the user — git is the user's job). No public API
  for SeqLisp users changes; Lisp-level `if`/`cond` are unaffected.

## Checkpoints

1. `seqc build src/repl.seq -o target/seqlisp` succeeds (currently fails at
   line 39).
2. `just test` — all Seq unit tests pass.
3. `just ci` — full suite (Seq + Lisp + LSP tests) passes.
4. Smoke test: `./target/seqlisp examples/*.slisp` runs cleanly. The
   tail-recursion test from `ARCHITECTURE.md` (10k-depth countdown) still
   completes without stack overflow, confirming TCO survived.
5. Spot-check one of the four `if "#t" else "#f" then` sites in `eval.seq`
   to confirm a representative rewrite reads correctly in context.

## Notes for future refactoring (do NOT do this pass)

Capture insights as `FOLLOWUP:` comments in the source while migrating —
don't act on them. The combinator form is going to make several existing
patterns either more obvious or more painful, and that signal is worth
recording while it's fresh:

- **The `if "#t" else "#f" then ssym` pattern** (4 sites in `eval.seq`)
  becomes `[ "#t" ] [ "#f" ] if ssym` — visually heavier. A small
  `bool->bool-sym` helper word would shrink each call site to one token.
- **Deeply nested keyword `if`s in `eval.seq`** that currently rely on
  visual indent to track which `then` matches which `if` will gain real
  bracket structure. Once migrated, sections that read awkwardly under
  the combinator form are signaling "this should be `match` or `cond`."
- **Dispatch-chain shape.** The 8-group dispatch from the roadmap was
  expressed as nested keyword conditionals. After migration, look at
  whether the chain reads better as a sequence of guarded quotations.
  Not worth bundling — but note any spots that obviously want the
  rework.
- **`while`/`until`/`times`** conversion (roadmap item, issue #51) is
  unrelated to the keyword change and stays out.

### One bundling candidate worth flagging

If — and only if — `eval.seq` migration surfaces a substantial cluster of
adjacent conditionals that read clearly as `cond`-pair lists under the new
form, converting *those specific sites* to the existing Seq `cond`
combinator in the same PR would be cheap (no extra type-check risk; just
a different combinator) and would avoid touching the same lines twice.
Anything else — split files, helper words, dispatch refactor — is fast-
follow material, not bundling material.
