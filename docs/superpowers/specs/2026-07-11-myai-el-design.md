# myai.el — AI-powered inline code editing for Emacs

**Date**: 2026-07-11
**Status**: Design (pre-implementation)
**Amendment**: 2026-07-11 — exact prompts from the neovim plugin source are locked in below. Fidelity to the original is a hard requirement (the user explicitly noted: *"make sure to stick to the prompts in the neovim example closely because we know they work"*).

## Overview

Port [neovim-ai-editing](https://github.com/m9p909/neovim-ai-editing) (`~/Documents/neovim-ai-editing` in this codebase) to Emacs Lisp as a standalone file in the kickstart.emacs config. The plugin lets you select code, describe a change in a prompt, and have the AI replace the targeted code in-place via SEARCH/REPLACE blocks.

The user is always in charge — the AI never edits without explicit invocation.

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

1. **`myai-system-prompt`** (defvar) — Locked to the neovim plugin's exact text (only word "Neovim" → "Emacs"; everything else verbatim). The proven text below is the *only* allowed content for this variable.

2. **`myai-edit`** (interactive command) — Main entry point. Calls `gptel-request` with system + user messages; callback is `myai--apply-edits`.

3. **`myai--build-context`** (private) — Takes target range (start/end line) or cursor line; returns alist with `:filepath`, `:filetype`, `:numbered-lines`. Matches `M.build_context` in `edit.lua:35-54` exactly.

4. **`myai--parse-blocks`** (private) — Parses `<<<< SEARCH\n...\n====\n...\n>>>>` blocks from response text. Strips markdown fences first via `myai--strip-fences`. Matches `M.parse_blocks` in `edit.lua:27-33` exactly.

5. **`myai--strip-fences`** (private) — Removes enclosing ` ```lang\n...\n``` ` if the model wraps its output. Matches `Utils.strip_fences` in `utils.lua:3-7` exactly.

6. **`myai--apply-blocks`** (private) — Applies SEARCH/REPLACE blocks sequentially to the buffer. Uses plain string matching (no regex). Reports success/failure per block. Matches `M.apply` in `edit.lua:68-88` exactly.

## Locked Prompts (verbatim from neovim plugin)

### System Prompt (`edit.lua:8-25`)

The exact text from the neovim plugin, with only "Neovim" → "Emacs":

```
You are an inline code editor for Emacs. You receive a file with line numbers and a cursor position. You return edits as one or more SEARCH/REPLACE blocks in this exact format:

<<<< SEARCH
exact original lines from the file
====
new lines to replace them with
>>>>

Rules:
- SEARCH must match text in the file exactly (whitespace-sensitive).
- Include enough context lines in SEARCH to be unambiguous.
- Multiple SEARCH/REPLACE blocks allowed, separated by a blank line.
- Output ONLY the blocks. No prose, no markdown fences, no explanation.
- If no edit is needed, output nothing.

Markers in the file:
- `--> N|` marks the line where the user's cursor is. This is the user's focal point — the edit they describe likely targets code at or near this line.
- `--> N|` and `<-- N|` bracket a visual selection when the user has selected a range of lines.
```

### User Message Format (`edit.lua:56-66`)

```
File: /path/to/file.py (python)

 1|import os
--> 2|x = 1
<-- 3|y = 2
 4|z = 3

User request: <input>

Output SEARCH/REPLACE blocks for the edits.
```

### Block Delimiter Pattern (Lua `edit.lua:27-33`)

The lua pattern `<<<< SEARCH\n(.-)\n====\n(.-)\n>>>>` translated to elisp regex:

```elisp
"<<<< SEARCH\n\\(.*?\\)\n====\n\\(.*?\\)\n>>>>"
```

(Non-greedy match between delimiters. The elisp equivalent of Lua's `.-` is `.*?` with non-greedy matching.)

### Context Line Prefix Format (`edit.lua:35-54`)

- Line numbers are right-padded to the width of the total line count: `printf "%Nd|" N`
- Cursor line: `"--> " .. prefix`
- Range start: `"--> " .. prefix`
- Range end: `"<-- " .. prefix`
- Range start == end (single-line selection): both markers on same line → `"--> <-- N|line"`

## Error Semantics (verbatim from neovim plugin)

| Condition | neovim message | our message (must match) |
|---|---|---|
| Empty instruction | "empty instruction" | "empty instruction" |
| No blocks parsed | "no SEARCH/REPLACE blocks found" | "no SEARCH/REPLACE blocks found" |
| Search not in buffer | "SEARCH block not found: " + first 60 chars | "SEARCH block not found: " + first 60 chars |
| gptel error | (surface) | (surface, log to *Messages* or minibuffer) |

## Integration in init.org

```elisp
;; Add lisp/ to load-path (uncomment existing line)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'myai)

;; In leader keys block, add a new "AI" category:
(start/leader-keys
  "a" '(:ignore t :wk "AI")
  "a e" '(myai-edit :wk "AI edit"))
```

## Dependencies

- **gptel** — Must be installed and configured with at least one backend. `myai.el` uses `gptel-request`. User must set up gptel's API key, model, endpoint separately.

- **No other dependencies** — minibuffer for input, standard `string-match` for parsing, `point-min`/`point-max` and `delete-region`/`insert` for buffer manipulation.

## Verification

1. `M-x myai-edit` is callable from any buffer
2. With a region active: target is the region
3. With no region: target is the current line
4. Empty input: `user-error`
5. AI returns valid SEARCH/REPLACE: edits applied, success message
6. AI returns no blocks: warning, no buffer change
7. AI returns search text not in buffer: warning, that block skipped, others continue

## Non-scope

- No streaming display during generation (gptel handles this)
- No chat history / conversation mode
- No multi-provider abstraction (gptel handles this)
- No non-interactive batch mode (unlike the neovim plugin's `:MyaiEdit prompt text` form)
- No visual UI beyond standard minibuffer

## Reference files (neovim plugin)

- `~/.local/share/nvim/lazy/neovim-ai-editing/lua/myai/edit.lua` — main logic, prompts, parser, apply
- `~/.local/share/nvim/lazy/neovim-ai-editing/lua/myai/utils.lua` — `strip_fences`
- `~/.local/share/nvim/lazy/neovim-ai-editing/lua/myai/init.lua` — user command (not ported; we use the leader key)
- `~/.local/share/nvim/lazy/neovim-ai-editing/lua/myai/prompt.lua` — floating window (not ported; we use minibuffer)
- `~/.local/share/nvim/lazy/neovim-ai-editing/lua/myai/api.lua` — curl API calls (not ported; gptel handles this)
