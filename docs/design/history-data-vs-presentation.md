# Design: Separate History Data from Presentation

## Problem

History currently muddles program data with display artifacts:

- **In-session recall**: buffer contains raw `\n` characters from the accumulated expression. The renderer tries to display these with `... ` continuation prompts, but cursor math breaks.
- **Disk persistence**: `history-to-string` joins entries with `\n`, and `history-load-lines` splits on `\n`. A multiline entry like `(define fact (lambda (n)\n  (if ...)))` gets split into separate lines on save/load. So in-session history and loaded-from-disk history behave differently for the same expression.
- **Continuation prompts** (`... `) are a display-time concern but keep leaking into the data path.

## Intent

One invariant: **history entries are complete, balanced expressions**. An entry is the exact text the user wrote, including their whitespace, minus any display chrome. The `... ` prompt was never typed — it's presentation.

When the user presses `k` to recall, they should see the expression rendered across multiple lines with their original formatting, whether the entry came from the current session or from disk. The behavior must be identical.

## Constraints

- History entries may contain `\n` — this is user data, not a delimiter.
- `~/.seqlisp_history` file format must support multiline entries.
- The `... ` prompt is display-only — never stored, never part of the buffer.
- Single-line editing (the common case) must not regress.
- Out of scope: j/k line navigation within a multiline buffer (future work per `multiline-repl-history.md`).

## Approach

### 1. Fix history persistence (the data bug)

The file format currently uses `\n` as both the entry delimiter and content character. Fix by escaping or using a different delimiter.

**Option A — Escape newlines**: Store `\n` within entries as `\\n` (literal backslash-n). Unescape on load. Simple, backwards-compatible for single-line entries.

**Option B — Record separator**: Use ASCII `\x1e` (record separator) between entries, `\n` within entries is literal. Cleaner but history file is less human-readable.

**Recommendation: Option A.** It's simpler, the history file stays readable, and single-line entries are unchanged.

### 2. Fix rendering (the presentation bug)

The renderer writes the buffer to the terminal. If the buffer contains `\n`, the terminal needs help:

- Before writing, `\x1b7` saves cursor position and `\x1b[J` clears to end of screen.
- Replace each `\n` in the buffer with `\n\r... ` when writing — carriage return to column 0, then the visual continuation prompt.
- After writing, `\x1b8` restores cursor to the start of line 1.
- Position cursor within the first line based on the buffer cursor position (clamped to first line length).

This keeps the presentation layer (`... `, ANSI escapes) entirely in the render function. The buffer and history never see `... `.

### 3. Data flow

```
User types line 1 → vim-edit returns "line1"
REPL accumulates: acc = "line1\n"
User types line 2 → vim-edit returns "  line2"
REPL accumulates: acc = "line1\n  line2\n"
Parens balance → history-add("line1\n  line2")  ← data, no "..."
                 ↓
              history-save → "line1\\n  line2\n" in file  ← escaped \n
                 ↓
              history-load → "line1\n  line2"  ← unescaped back

User presses k → buffer = "line1\n  line2"
Renderer shows:
  ○ > line1
  ... line2          ← "..." is render-only
```

## Checkpoints

1. **Persistence round-trip**: Enter multiline expression, quit, restart, press `k` — get the same expression back with original whitespace.
2. **No `...` in data**: Add `(print history-entry)` debug and confirm no `...` in the stored string.
3. **Display correct**: Recalled multiline entry shows `... ` at start of continuation lines, no compounding whitespace.
4. **Single-line unchanged**: Single-line entries work exactly as before (save, load, recall, edit).
