# Self-Hosting SeqLisp

## Intent

Write enough of SeqLisp's own toolchain in SeqLisp itself to demonstrate
the language is capable of processing its own source code: tokenize, parse,
and evaluate `.slisp` from within `.slisp`.

Why: self-hosting is the strongest proof that a language is "real." It
exercises homoiconicity, validates the primitive set, and unlocks self-hosted
tooling (linter, formatter, REPL) as natural follow-ons. The LSP server
(705 lines of `.slisp`) already proves the language can do substantial work;
self-hosting is the next logical step.

## Constraints

- **Don't break existing programs.** All additions are new `.slisp` library
  code or additive builtins — no changes to existing eval semantics.
- **Out of scope:** compilation (Lisp-to-Seq), type system integration,
  full Scheme/CL compatibility. These remain long-term research items.
- **Seq compiler changes are fair game** — additive feature requests to
  `navicore/patch-seq` are welcome when they unblock self-hosting.

## Approach

Four phases, each independently useful:

### Phase 1 — Tokenizer in SeqLisp

A `(tokenize source-string)` function that returns a list of token records.
Each token carries source spans (line, column, offset) from the start —
adding spans later is harder than doing it up front. The LSP already does
character-by-character scanning via `char-at`/`substring` so the primitives
exist. Likely gaps to resolve early:

- **`char-code` / `code-char`** — comparing single-char strings works
  (the LSP does it) but numeric char codes would be cleaner and faster.
  Candidate for a patch-seq feature request or a small eval.seq builtin.
- **`digit?` / `alpha?`** — can be built in SeqLisp on top of `char-code`
  or string comparisons, but native builtins would be more ergonomic.

Deliver: `lib/reader/tokenizer.slisp` + test suite.

### Phase 2 — Parser in SeqLisp

A `(parse tokens)` function that returns S-expressions. Recursive descent
over the token list. Must handle `'`, `` ` ``, `,`, `,@` sugar.

Deliver: `lib/reader/parser.slisp` + test suite.

### Phase 3 — File I/O and `load`

Currently only stdin/stdout. Self-hosting needs:

- `(read-file path)` → string contents
- `(write-file path content)` → writes file
- `(file-exists? path)` → boolean
- `(load path)` → read + tokenize + parse + eval

Seq already has the primitives we need: `file.slurp`, `file.spit`,
`file.exists?`, `file.append`. These just need thin wrappers exposed as
SeqLisp builtins in eval.seq. No patch-seq feature request needed for
basic file I/O.

### Phase 4 — Self-hosted eval loop

Combine phases 1-3 into a fully self-hosted evaluator written in SeqLisp.
This means eval-in-Lisp, not just delegating to `eval-with-errors`. The
goal is the complete loop in SeqLisp: read source → tokenize → parse →
eval → print.

The self-hosted eval needs: environment management, special form dispatch,
builtin function application, macro expansion, and closure creation — all
in `.slisp`. This is the most ambitious phase but it's what makes
self-hosting meaningful.

## Checkpoints

| Phase | Verified when |
|-------|---------------|
| 1 | `(tokenize "(define (f x) (+ x 1))")` returns correct token list |
| 2 | `(parse (tokenize "(if #t 1 2)"))` returns `(if #t 1 2)` as data |
| 3 | `(load "examples/factorial.slisp")` runs and prints output |
| 4 | A `.slisp` program can read, parse, and evaluate another `.slisp` file |

## Resolved Decisions

- **Spans up front.** Tokens carry source spans from day one. Adding them
  later is harder than doing it right the first time.
- **Eval in Lisp.** Phase 4 is a real self-hosted evaluator, not a wrapper
  around `eval-with-errors`. That's what makes it meaningful.
- **File I/O covered.** Seq has `file.slurp`, `file.spit`, `file.exists?`,
  `file.append` — enough for our needs. Just need eval.seq wrappers.

## Seq Stdlib Available for Feature Requests

Reference: https://www.navicore.tech/patch-seq/STDLIB_REFERENCE.html#io-operations

Already available in Seq (expose as needed):
- `file.slurp` / `file.spit` / `file.append` / `file.exists?` / `file.delete` / `file.size`
- `dir.exists?` / `dir.make` / `dir.list`
- `terminal.read-char` (single byte, blocking)

If we need more (e.g., `string.char-at` as a code point), file issues
on `navicore/patch-seq`.
