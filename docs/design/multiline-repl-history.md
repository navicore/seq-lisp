# Design: Multiline REPL History Editing

## Intent

When a user enters a multiline expression like:
```
(define fact (lambda (n)
  (if (= n 0)
    1
    (* n (fact (- n 1))))))
```
and later presses `k` to recall it, they should get the **full expression** back as an editable multiline buffer with vi motions working across lines — not just the last line.

History already stores complete expressions (with embedded newlines). The gap is that the vim-line editor renders and navigates as if the buffer is a single line.

## Current State

- **History**: expression-based (correct). Multiline entries stored as strings with `\n`.
- **Editor buffer**: flat string with integer cursor position. No concept of lines.
- **Rendering**: writes buffer to terminal in one shot. No line-by-line positioning.
- **j/k in normal mode**: bound to history up/down, not line movement.
- **Cursor clamping**: `[0, len-1]` on string length, not line-aware.

## Constraints

- Must not break single-line editing (the common case).
- Must not break history persistence (`~/.seqlisp_history`).
- Must not require external dependencies (pure Seq terminal FFI).
- vi motions (`h`, `l`, `w`, `b`, `d`, `c`, `x`, `$`, `0`) must still work.
- Out of scope: visual mode, horizontal scrolling, line wrapping awareness.

## Key Decision: j/k Semantics

The hardest design choice: `j`/`k` currently mean "history next/prev" but in a multiline buffer they should mean "line down/up". Options:

| Option | j/k in single-line | j/k in multiline | History nav |
|--------|--------------------|--------------------|-------------|
| A. Context-switch | history | line movement | Ctrl-p/Ctrl-n always |
| B. Always line-based | line (no-op, 1 line) | line movement | Ctrl-p/Ctrl-n always |
| C. Edge-aware | history (only 1 line) | line movement, history at top/bottom edge | j/k at edges |

**Recommendation: Option C** — least surprising. When the cursor is on the last line and the user presses `j`, navigate history forward. When on the first line, `k` navigates history backward. When in the middle, `j`/`k` move between lines. This matches how multi-line editing works in zsh and fish.

## Approach

### Phase 1: Line-aware cursor model
- Add `cursor-line` / `cursor-col` derived from buffer string + cursor position.
- Add helpers: `line-count`, `line-start-offset`, `line-length`.
- Rendering: clear and redraw each line with ANSI cursor positioning.
- Prompt: first line gets `> `, continuation lines get `... `.

### Phase 2: j/k line movement
- In normal mode, `j`/`k` move cursor between lines (preserving column where possible).
- At buffer edges, fall through to history navigation.

### Phase 3: Multiline insert
- `Enter` in insert mode: if parens are balanced, submit. If not, insert newline and continue.
- `o`/`O` in normal mode: open line below/above.

### LOE Estimate

| Phase | Effort | Risk |
|-------|--------|------|
| Phase 1: line-aware rendering | 2-3 days | Medium — terminal coordinate math is fiddly |
| Phase 2: j/k line movement | 1 day | Low — once cursor model works, movement is straightforward |
| Phase 3: multiline insert | 1 day | Medium — paren-balance check on Enter needs care |
| Testing / edge cases | 1-2 days | High — terminal behavior varies, hard to automate |
| **Total** | **5-7 days** | |

The biggest risk is Phase 1: getting terminal rendering correct for multi-line buffers with ANSI escapes. Everything else builds on that foundation.

## Checkpoints

1. **Phase 1 done**: Recalling a multiline history entry renders correctly across multiple terminal lines with proper prompts.
2. **Phase 2 done**: `j`/`k` move between lines in a multiline buffer; at edges, navigate history.
3. **Phase 3 done**: Typing a multiline expression works with `Enter` inserting newlines until parens balance.
4. **Regression check**: All existing single-line editing works unchanged.
