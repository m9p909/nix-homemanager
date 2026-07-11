# myai.el — AI-powered inline code editing for Emacs

**Date**: 2026-07-11  
**Status**: Design (pre-implementation)

## Overview

Port the [neovim-ai-editing](https://github.com/m9p909/neovim-ai-editing) plugin (~263 lines of Lua) to Emacs Lisp as a standalone file in the kickstart.emacs config. The plugin lets you select code, describe a change in a prompt, and have the AI replace the targeted code in-place via SEARCH/REPLACE blocks.

## Architecture

Single file: `~/.config/emacs/lisp/myai.el`

Provides one interactive command: `myai-edit`

### Data Flow

```
C-SPC a e
  → myai-edit command
    → Determine target: active region → region lines; otherwise → current line
    → Minibuffer prompt: "Edit: "
    → If empty input → user-error
    → Build context string (full buffer with -->/<-- markers around target lines)
    → gptel-request (system-prompt + context + instruction, async callback)
    → Callback: parse SEARCH/REPLACE blocks from response
    → Apply each block sequentially to buffer via string replacement
    → Message: "Applied N edits" or error per block
```

### Components

1. **`myai-system-prompt`** (defvar) — System prompt instructing the AI to return only SEARCH/REPLACE blocks. Same spirit as the neovim plugin, adapted for Emacs context.

2. **`myai-edit`** (interactive command) — Main entry point. Calls gptel-request with:
   - System message: `myai-system-prompt`
   - User message: buffer context + instruction
   - Callback: `myai--apply-edits`

3. **`myai--build-context`** (private) — Takes target range (start/end line), returns string of numbered buffer lines with `-->`/`<--` markers bracketing the target.

4. **`myai--parse-blocks`** (private) — Parses `<<<< SEARCH\n...\n====\n...\n>>>>` blocks from response text. Strips markdown fences first.

5. **`myai--apply-blocks`** (private) — Applies SEARCH/REPLACE blocks sequentially to the buffer. Uses plain string matching. Reports success/failure per block.

### Context Format

```
 1|package main
--> 2|func main() {
<-- 3|    fmt.Println("hello")
 4|}
```

- `-->` marks the first target line (region start or cursor line)
- `<--` marks the last target line (region end; same as `-->` if single line)
- File path and language included in preamble

### AI Response Protocol

```
<<<< SEARCH
func main() {
    fmt.Println("hello")
}
====
func main() {
    fmt.Println("hello, world")
    fmt.Println("goodbye")
}
>>>>
```

Multiple blocks separated by blank line. Applied sequentially.

### Error Cases

| Condition | Behavior |
|---|---|
| Empty instruction | `user-error` — no API call made |
| gptel error / no response | Surfaced by gptel (no custom handling needed) |
| No SEARCH/REPLACE blocks in response | `message` warning, no buffer changes |
| SEARCH not found in buffer | `message` warning per block, skip that block |
| All blocks applied | `message "Applied N edits"` |

### Integration in init.org

```elisp
;; Add lisp/ to load-path (uncomment existing line)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'myai)

;; In leader keys block:
(start/leader-keys
  "a" '(:ignore t :wk "AI")
  "a e" '(myai-edit :wk "AI edit"))
```

### Dependencies

- **gptel** — Must be installed and configured with at least one backend. The user configures gptel separately (API key, model, endpoint). `myai.el` uses `gptel-request` directly.

- **No other dependencies** — minibuffer for input, `string-match` for parsing, standard buffer manipulation functions.

## Verification

After implementation:
1. Load the file and verify `myai-edit` is callable
2. Test with a simple instruction on a known buffer
3. Verify region and single-line modes both work
4. Verify error cases (empty input, no blocks returned)

## Non-scope

- No streaming display during generation (gptel handles this)
- No chat history / conversation mode
- No multi-provider abstraction (gptel handles this)
- No visual-mode support beyond Emacs's standard region
- No non-interactive batch mode (unlike the neovim plugin's `:MyaiEdit prompt text` form)
