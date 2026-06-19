# Kickstart.nvim Cherry-Pick Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cherry-pick non-architectural improvements from kickstart.nvim@f0a2108 (2026-06-11) into the user's lazy.nvim-based neovim config, preserving all existing customizations and Neovim 0.11.6 compatibility.

**Architecture:** Keep lazy.nvim (do NOT migrate to vim.pack). Apply targeted edits to 4 files: `.stylua.toml` (formatting option), `lua/kickstart/health.lua` (version check), `lua/kickstart/plugins/gitsigns.lua` (improved keymaps), and `init.lua` (5 small improvements). All 8 custom plugins under `lua/custom/plugins/` remain untouched.

**Tech Stack:** Lua, Neovim 0.11.6, lazy.nvim, home-manager (Nix), stylua

**Spec:** `docs/superpowers/specs/2026-06-19-kickstart-merge-design.md`

---

## File Structure

| File | Change | Responsibility |
|------|--------|----------------|
| `config/nvim/.stylua.toml` | Modify (1 line) | Lua formatter config — add `collapse_simple_statement` |
| `config/nvim/lua/kickstart/health.lua` | Modify (1 line) | `:checkhealth kickstart` version gate — bump to 0.11 |
| `config/nvim/lua/kickstart/plugins/gitsigns.lua` | Modify (on_attach body) | Recommended git hunk keymaps — fix `hu` bug, add `hi`/`hQ`/`hq`/`tw`/`ih` |
| `config/nvim/init.lua` | Modify (6 edits) | Main config — `vim.loader.enable`, which-key groups, telescope keymaps, mini.ai, uncomment gitsigns |

**Customizations to preserve (DO NOT TOUCH):**
- `init.lua:177` — `jk` insert-mode exit
- `init.lua:184` — `jk` terminal-mode exit
- `init.lua:487` — `nvim-java/nvim-java` LSP dependency
- `init.lua:562` — `gd` goto definition keymap
- `init.lua:570` — `gW` workspace symbols keymap
- `init.lua:720-722` — `nil` in mason ensure-installed
- `init.lua:841` — blink.cmp `preset = 'enter'`
- `init.lua:900` — `tokyonight-night` colorscheme
- `lua/kickstart/plugins/neo-tree.lua` — `<leader>o` keymap, `filtered_items` showing dotfiles
- `lua/custom/plugins/*` — all 8 custom plugins

---

### Task 1: Trivial config files (stylua + health)

**Files:**
- Modify: `config/nvim/.stylua.toml:6`
- Modify: `config/nvim/lua/kickstart/health.lua:15`

- [ ] **Step 1: Add `collapse_simple_statement` to .stylua.toml**

Edit `config/nvim/.stylua.toml` — append after `call_parentheses = "None"`:

oldString:
```
quote_style = "AutoPreferSingle"
call_parentheses = "None"
```

newString:
```
quote_style = "AutoPreferSingle"
call_parentheses = "None"
collapse_simple_statement = "Always"
```

- [ ] **Step 2: Bump health.lua version check to 0.11**

Edit `config/nvim/lua/kickstart/health.lua:15`:

oldString:
```
  if vim.version.ge(vim.version(), '0.10-dev') then
```

newString:
```
  if vim.version.ge(vim.version(), '0.11') then
```

- [ ] **Step 3: Verify home-manager build succeeds**

Run: `home-manager build --flake ~/.config/home-manager#jack`
Expected: builds with no errors (exit 0)

- [ ] **Step 4: Commit**

```bash
git add config/nvim/.stylua.toml config/nvim/lua/kickstart/health.lua
git commit -m "chore(nvim): bump stylua collapse option and health check to 0.11"
```

---

### Task 2: Gitsigns recommended keymaps (fix bug + add keymaps)

**Files:**
- Modify: `config/nvim/lua/kickstart/plugins/gitsigns.lua` (full rewrite of file)

This task rewrites the gitsigns keymap module to match kickstart@f0a2108's improved keymaps while keeping the lazy.nvim `return { {..., opts = {...} } }` spec format. Changes:
- **Bug fix:** `<leader>hu` → `undo_stage_hunk` (was incorrectly `stage_hunk`)
- **New:** `<leader>hi` (preview inline), `<leader>hQ`/`<leader>hq` (quickfix lists), `<leader>tw` (word-diff toggle), `ih` (text object)
- **Changed:** `<leader>hb` → `blame_line { full = true }`
- **Removed:** `<leader>tD` (was a misnomer — `preview_hunk_inline` is not a toggle; replaced by `hi`)

- [ ] **Step 1: Replace gitsigns.lua with improved keymaps**

Write the full new content to `config/nvim/lua/kickstart/plugins/gitsigns.lua`:

```lua
-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
        map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function() gitsigns.diffthis '@' end, { desc = 'git [D]iff against last commit' })
        map('n', '<leader>hQ', function() gitsigns.setqflist 'all' end, { desc = 'git hunk [Q]uickfix list (all files in repo)' })
        map('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff' })

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
      end,
    },
  },
}
```

- [ ] **Step 2: Verify home-manager build succeeds**

Run: `home-manager build --flake ~/.config/home-manager#jack`
Expected: builds with no errors (exit 0)

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/kickstart/plugins/gitsigns.lua
git commit -m "fix(nvim): gitsigns hu undo bug, add hi/hQ/hq/tw/ih keymaps"
```

---

### Task 3: init.lua improvements (6 edits)

**Files:**
- Modify: `config/nvim/init.lua` at 6 locations

All edits preserve existing customizations. Each edit is independent and can be applied in sequence.

- [ ] **Step 1: Add `vim.loader.enable()` for faster startup**

Edit `config/nvim/init.lua` — insert after the header comment block (line 85 `--]]`), before the leader key setup (line 87):

oldString:
```
--]]

-- Set <space> as the leader key
```

newString:
```
--]]

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set <space> as the leader key
```

- [ ] **Step 2: Update which-key spec (add `gr` group, `s` visual mode)**

Edit `config/nvim/init.lua:345-349`:

oldString:
```
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
```

newString:
```
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
```

- [ ] **Step 3: Add `<leader>sc` telescope keymap and make `<leader>sw` work in visual mode**

Edit `config/nvim/init.lua:432` — change `sw` to work in both normal and visual mode:

oldString:
```
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
```

newString:
```
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
```

Then edit `config/nvim/init.lua:436` — add `sc` after the `s.` keymap:

oldString:
```
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '  [ ] Find existing buffers' })
```

newString:
```
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '  [ ] Find existing buffers' })
```

- [ ] **Step 4: Add `follow = true` to `<leader>sn` (config is a symlink via home-manager)**

Edit `config/nvim/init.lua:458-460`:

oldString:
```
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
```

newString:
```
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true }
      end, { desc = '[S]earch [N]eovim files' })
```

- [ ] **Step 5: Update mini.ai mappings (forward-compatible with 0.12 incremental selection)**

Edit `config/nvim/init.lua:916`:

oldString:
```
      require('mini.ai').setup { n_lines = 500 }
```

newString:
```
      require('mini.ai').setup {
        mappings = {
          around_next = 'aa',
          inside_next = 'ii',
        },
        n_lines = 500,
      }
```

- [ ] **Step 6: Uncomment gitsigns recommended keymaps module**

Edit `config/nvim/init.lua:984`:

oldString:
```
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
```

newString:
```
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommended keymaps
```

- [ ] **Step 7: Verify home-manager build succeeds**

Run: `home-manager build --flake ~/.config/home-manager#jack`
Expected: builds with no errors (exit 0)

- [ ] **Step 8: Commit**

```bash
git add config/nvim/init.lua
git commit -m "feat(nvim): cherry-pick kickstart improvements (loader, keymaps, mini.ai)"
```

---

### Task 4: Verification (build + nvim smoke test)

**Files:** None modified — verification only.

- [ ] **Step 1: Run home-manager build (final check)**

Run: `home-manager build --flake ~/.config/home-manager#jack`
Expected: builds with no errors (exit 0). If errors, read the output and fix before applying.

- [ ] **Step 2: Apply the configuration**

Run: `home-manager switch --flake ~/.config/home-manager#jack` (or the `update` alias)
Expected: succeeds, symlinks updated.

- [ ] **Step 3: Ask user to run nvim smoke tests**

The user must run these manually (we cannot run nvim interactively). Ask them to:

1. `nvim` — confirm lazy.nvim loads all plugins with no errors on startup
2. `:checkhealth kickstart` — should report OK (version 0.11.6 passes the `0.11` gate)
3. `<leader>sc` — Telescope commands picker opens
4. `<leader>sn` — finds neovim config files (follow=true traverses the home-manager symlink)
5. In a git repo: `<leader>hs` stages a hunk, `<leader>hu` undoes it (bug fix verified), `<leader>hi` previews inline, `v` select + `ih` selects hunk text object
6. `v` select a word + `<leader>sw` — greps the selection (visual mode now works)
7. `<leader>` (wait for which-key) — confirm `gr` LSP Actions group and `s` Search group appear in both normal and visual mode

- [ ] **Step 4: Final commit if any fixes were needed**

If the smoke tests revealed issues that required fixes, commit those fixes. Otherwise, no action needed — all changes were committed in Tasks 1-3.

---

## Self-Review

**Spec coverage:**
- ✅ `vim.loader.enable()` → Task 3 Step 1
- ✅ which-key `gr` group + `s` visual mode → Task 3 Step 2
- ✅ Telescope `<leader>sc` + `<leader>sw` visual + `<leader>sn` follow → Task 3 Steps 3-4
- ✅ mini.ai `aa`/`ii` mappings → Task 3 Step 5
- ✅ Uncomment gitsigns → Task 3 Step 6
- ✅ gitsigns keymap fixes (hu bug, hi/hQ/hq/tw/ih) → Task 2
- ✅ health.lua 0.11 → Task 1 Step 2
- ✅ .stylua.toml collapse → Task 1 Step 1
- ✅ Verification (build + smoke test) → Task 4
- ✅ Customizations preserved — explicitly listed in File Structure section

**Placeholder scan:** No TBD/TODO. All code blocks contain exact content. All commands specified with expected output.

**Type consistency:** gitsigns function names (`undo_stage_hunk`, `preview_hunk_inline`, `setqflist`, `select_hunk`, `toggle_word_diff`, `blame_line`) all verified against the upstream diff. init.lua line numbers verified against current file state.

**Ordering:** Task 2 (gitsigns.lua) before Task 3 Step 6 (uncomment gitsigns require) — the module must be updated before it's enabled.
