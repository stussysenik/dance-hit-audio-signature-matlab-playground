# Portable LazyVim Config

Minimal, powerful LazyVim setup with multi-language support, formatters, linters, and tmux config.

## Quick Install

```bash
# On any new machine:
git clone git@github.com:senik/nvim-portable.git
cd nvim-portable
bash install.sh
# Open nvim — everything auto-installs on first launch
```

## What's Included

### Neovim Plugins

| File | What it does |
|------|-------------|
| `lua/plugins/neo-tree.lua` | `E` expand all / `z` collapse all folders in explorer |
| `lua/plugins/folding.lua` | Treesitter-based code folding (`za` toggle, `zM` close all, `zR` open all) |
| `lua/plugins/langs.lua` | Full language stack: LSP + formatters + linters + treesitter |

### Languages Configured

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| TypeScript/JS | tsserver | prettier | eslint_d |
| Python | pyright | ruff/black | ruff |
| C/C++ | clangd | clang-format | clangd |
| Elixir | elixir-ls | mix format | — |
| Ruby/Rails | solargraph | rubocop | rubocop |
| Zig | zls | zigfmt | — |
| Kotlin | kotlin-ls | ktlint | — |
| Swift | sourcekit | swiftformat | — |
| OCaml | ocamllsp | ocamlformat | — |
| Lua | lua_ls | stylua | — |
| Shell | bashls | shfmt | shellcheck |
| Common Lisp | — | — | treesitter highlighting |
| MATLAB | matlab_ls | — | — |

### Terminal Workflow

**Ghostty is the recommended local workflow.** Native splits and tabs are simpler than tmux for day-to-day use:

| Action | Ghostty Key |
|--------|-------------|
| Vertical split | `Cmd+D` |
| Horizontal split | `Cmd+Shift+D` |
| New tab | `Cmd+T` |
| Switch panes | `Cmd+[` / `Cmd+]` |

Tmux config is included for **SSH/remote sessions** where you need persistent terminals that survive disconnects.

### Tmux Config (`.tmux.conf`) — Optional

Prefix changed from `Ctrl+B` to **`Ctrl+Space`**. Vim-style navigation.

| Action | Key |
|--------|-----|
| Vertical split | `Ctrl+Space` then `\|` |
| Horizontal split | `Ctrl+Space` then `-` |
| New window | `Ctrl+Space` then `c` |
| Switch panes | `Alt+h/j/k/l` (no prefix) |
| Switch windows | `Alt+1/2/3/4/5` (no prefix) |
| Resize panes | `Ctrl+Space` then `H/J/K/L` |
| Reload config | `Ctrl+Space` then `r` |

### Mobile Device Testing

Test on a real phone hitting your local dev server:

**Same WiFi (simplest, no install):**
```bash
# 1. Start dev server exposed to network
npm run dev -- --host
# or: next dev -H 0.0.0.0

# 2. Get your Mac's local IP
ipconfig getifaddr en0
# → 192.168.1.42

# 3. Open on phone: http://192.168.1.42:3000
```

**Different network / need HTTPS:**
```bash
# ngrok (simplest tunnel)
brew install ngrok
ngrok http 3000
# → https://abc123.ngrok-free.app  ← open on any device, anywhere

# Cloudflare Tunnel (free, production-grade)
brew install cloudflared
cloudflared tunnel --url http://localhost:3000
# → https://random-words.trycloudflare.com
```

| Method | Install needed | HTTPS | Speed |
|--------|---------------|-------|-------|
| Same WiFi + `--host` | None | No | Instant |
| ngrok | `brew install ngrok` | Yes | 2 seconds |
| Cloudflare Tunnel | `brew install cloudflared` | Yes | 2 seconds |

Same WiFi covers 90% of cases. Ngrok/Cloudflare for the rest.

## Manual Installs (not auto-managed)

```bash
# OCaml
brew install opam && opam init
eval $(opam env)
opam install ocaml-lsp-server ocamlformat

# Swift formatter
brew install swiftformat

# Zig LSP
brew install zls
```

## Key Shortcuts Reference

### Navigation
| Key | Action |
|-----|--------|
| `<leader>ff` | Find file |
| `<leader>sg` | Grep text across project |
| `<leader>ss` | Symbols in current file (definitions only) |
| `<leader>sS` | Symbols across project (definitions only) |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `Ctrl+o` | Jump back |
| `Ctrl+i` | Jump forward |
| `/` | Search in file (like Cmd+F) |
| `gg` | Top of file |
| `G` | Bottom of file |
| `42G` | Go to line 42 |

### Editing
| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `<leader>cr` | Rename symbol everywhere |
| `<leader>ca` | Code action (auto-fix) |
| `<leader>cf` | Format file |
| `<leader>cs` | Outline sidebar |

### File Explorer (neo-tree)
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle explorer |
| `E` | Expand all folders |
| `z` | Collapse all folders |

## Learnings & Gotchas

### Mason plugin load ordering

LazyVim manages three Mason-related plugins that **must load in this order**:

1. `mason-org/mason.nvim` — package manager (installs LSPs, formatters, linters)
2. `mason-org/mason-lspconfig.nvim` — bridges Mason and nvim-lspconfig
3. `neovim/nvim-lspconfig` — configures LSP servers

**LazyVim handles this ordering automatically.** Don't override `priority`, `dependencies`, or `event` on these plugins unless you absolutely know what you're doing — breaking the order causes LSP servers to silently not attach.

What's safe: adding `opts` to extend `ensure_installed` or `servers` (deep-merges with LazyVim defaults).

### Mason org migration

Mason moved from `williamboman/mason.nvim` to `mason-org/mason.nvim` (same for mason-lspconfig). The old URLs still redirect but use the new org name going forward.

### Extras must go in `lazyvim.json`, not plugin files

LazyVim loads specs in order: **core → extras → user plugins**. If you import extras inside `lua/plugins/langs.lua`, they load during the user-plugin phase (too late). LazyVim detects this and shows `lazyvim_check_order` warnings.

**Wrong** — importing extras in a plugin file:
```lua
-- lua/plugins/langs.lua
return {
  { import = "lazyvim.plugins.extras.lang.typescript" }, -- ← loads too late
}
```

**Right** — declare extras in `lazyvim.json` (or use `:LazyExtras` UI):
```json
{
  "extras": [
    "lazyvim.plugins.extras.lang.typescript",
    "lazyvim.plugins.extras.lang.python"
  ]
}
```

This config uses `lazyvim.json`. The `langs.lua` file only contains custom `opts` overrides (mason, conform, lint, lspconfig, treesitter).

### Adding custom opts is safe

When you add `opts` to a plugin that LazyVim already configures (mason, conform, nvim-lint, lspconfig, treesitter), lazy.nvim **deep-merges** your opts with LazyVim's. Your `ensure_installed` list extends theirs, your `servers` table adds to theirs. You're not replacing — you're extending.

### Swift has no LazyVim extra

There's no `lazyvim.plugins.extras.lang.swift` — importing it errors on fresh install. Swift LSP works through sourcekit-lsp (comes with Xcode), and swiftformat is installed manually via `brew install swiftformat`.

## Structure

```
nvim-portable/
├── init.lua                    # Entry point
├── lazyvim.json                # LazyVim metadata
├── stylua.toml                 # Lua formatter config
├── install.sh                  # One-command setup
├── .tmux.conf                  # Tmux configuration
├── lua/
│   ├── config/
│   │   ├── lazy.lua            # Plugin manager bootstrap
│   │   ├── options.lua         # Vim options
│   │   ├── keymaps.lua         # Custom keybindings
│   │   └── autocmds.lua        # Auto-commands
│   └── plugins/
│       ├── neo-tree.lua        # Explorer expand/collapse
│       ├── folding.lua         # Code folding
│       └── langs.lua           # All language support
```
