# Design: Cherry-pick kickstart.nvim improvements (keep lazy.nvim)

**Date:** 2026-06-19
**Upstream ref:** kickstart.nvim@f0a2108ed51547793c758d9318bad94f242b22e5 (2026-06-11)
**Approach:** Cherry-pick non-architectural improvements; keep lazy.nvim + Neovim 0.11.6

## Context

The user's neovim config at `config/nvim/` is a clone of kickstart.nvim that has diverged with customizations: `jk` insert/terminal exit keymaps, `nvim-java` LSP dependency, `nil` formatter in mason ensure-installed, `gd`/`gW` extra LSP keymaps, blink.cmp `preset='enter'`, and 8 custom plugins under `lua/custom/plugins/` (avante, claude_code/opencode, clojure, copilot, mkdir, neoconf, persistence, init).

The latest kickstart made a breaking architectural change: it dropped `lazy.nvim` for `vim.pack` (Neovim 0.12+'s built-in plugin manager), restructured `init.lua` into labeled `do...end` sections, and rewrote every plugin module from lazy specs to `vim.pack.add` + direct `setup()` calls. The user runs Neovim **0.11.6** via home-manager. A full migration would require upgrading Neovim and rewriting all 8 custom plugins (avante alone has ~10 dependencies relying on lazy-loading).

**Decision (user-approved):** Cherry-pick only the safe, non-architectural improvements. Keep lazy.nvim. No Neovim upgrade. Custom plugins untouched.

## Scope

### Files modified (4)

#### 1. `config/nvim/init.lua`

Six targeted edits. All existing customizations preserved.

1. **Add `vim.loader.enable()`** at the top of the options section (after the leader-key setup, before `vim.o.number`). Speeds up startup by caching compiled Lua modules. Available since Neovim 0.9, safe on 0.11.6.

2. **which-key spec** — update the `spec` table:
   - `{ '<leader>s', group = '[S]earch' }` → `{ '<leader>s', group = '[S]earch', mode = { 'n', 'v' } }` (so search group shows in visual mode too)
   - Add `{ 'gr', group = 'LSP Actions', mode = { 'n' } }`

3. **Telescope keymaps** (inside the telescope `config` function):
   - Add `vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })`
   - Change `<leader>sw` from `('n', ...)` to `({ 'n', 'v' }, ...)` so grep-string works on visual selection
   - Add `follow = true` to the `<leader>sn` `find_files` call (important: the user's nvim config is a symlink into the home-manager store, so `follow` ensures the search traverses it correctly)

4. **mini.ai setup** — add mappings to avoid conflict with 0.12's built-in incremental selection (forward-compatible, safe on 0.11):
   ```lua
   require('mini.ai').setup {
     mappings = {
       around_next = 'aa',
       inside_next = 'ii',
     },
     n_lines = 500,
   }
   ```

5. **Uncomment `require 'kickstart.plugins.gitsigns'`** (currently line 984). This enables the improved gitsigns keymaps module.

#### 2. `config/nvim/lua/kickstart/plugins/gitsigns.lua`

Replace contents with the improved keymaps, keeping the lazy.nvim `return {}` spec format. Changes from the current version:

- **Bug fix:** `<leader>hu` → `gitsigns.undo_stage_hunk` (was incorrectly `gitsigns.stage_hunk`)
- **New keymaps:**
  - `<leader>hi` — preview hunk inline
  - `<leader>hQ` — quickfix list for all files in repo
  - `<leader>hq` — quickfix list for current file
  - `<leader>tw` — toggle intra-line word diff
  - `ih` (operator-pending + visual) — select hunk text object
- **Refinements:**
  - `<leader>hb` → `function() gitsigns.blame_line { full = true } end`
  - `<leader>hD` → `function() gitsigns.diffthis '@' end`

#### 3. `config/nvim/lua/kickstart/health.lua`

Change the version check from `vim.version.ge(vim.version(), '0.10-dev')` to `vim.version.ge(vim.version(), '0.11')`. The user is on 0.11.6; bumping to `0.12` (what upstream did) would falsely report their install as out of date.

#### 4. `config/nvim/.stylua.toml`

Add `collapse_simple_statement = "Always"` to match kickstart's current formatting style. Purely cosmetic; aligns `stylua` output with upstream.

### Files NOT modified

- `lua/kickstart/plugins/{debug,autopairs,indent_line,lint,neo-tree}.lua` — upstream changes are only the lazy→vim.pack reformat. No functional gain, and neo-tree carries the user's customizations (`<leader>o` keymap, `filtered_items` showing dotfiles/gitignored).
- `lua/custom/plugins/*` — all 8 custom plugins untouched.
- `init.lua` diagnostic config — left as-is. The user's config uses nerd-font signs + a custom `virtual_text` format function. Upstream's new `jump.on_jump` auto-float and `virtual_lines` toggle likely require 0.12 APIs; not worth the risk on 0.11.6.
- `README.md`, `.gitignore`, `LICENSE.md`, `doc/kickstart.txt` — non-functional.

## Verification

1. `home-manager build --flake ~/.config/home-manager#jack` — must succeed with no errors.
2. `nvim` — confirm lazy.nvim loads all plugins without errors.
3. `:checkhealth kickstart` — should report OK (version check passes on 0.11.6).
4. Manual smoke test:
   - `<leader>sc` opens Telescope commands
   - `<leader>sn` finds neovim config files (follow enabled)
   - `v` select + `<leader>sw` greps selection
   - In a git repo: `<leader>hs` stages hunk, `<leader>hu` undoes it, `<leader>hi` previews inline, `ih` text object works
   - `:lua vim.loader.enable()` already active (faster startup)

## Out of scope / future work

- Neovim 0.12+ upgrade and full vim.pack migration (separate spec if pursued)
- Diagnostic `virtual_lines` / `jump.on_jump` (depends on 0.12+)
- LSP picker migration to separate Telescope autocmd (architectural; no gain on 0.11)
