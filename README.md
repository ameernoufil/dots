# dotfiles

macOS config for zsh, Neovim, Zed, Ghostty, AeroSpace, tmux and herdr, plus helper scripts for jumping between projects and git worktrees.

Nothing installs automatically. Each entry is symlinked into `$HOME` by hand (see [Symlinks](#symlinks)).

## Layout

| Path in repo | Live path | What it is for |
| --- | --- | --- |
| `.zshrc` | `~/.zshrc` | Oh My Zsh (`awesomepanda` theme, git/autosuggestions/syntax-highlighting plugins), `nvim` as editor, nvm, bun and gcloud completions, `Ctrl-F` runs `sessionizer`, sources `bin/fzf-git.sh` and `.zshrc.local` |
| `.zshrc.local` | `~/.zshrc.local` | **Gitignored.** Machine-specific shell functions |
| `.zshenv` | `~/.zshenv` | **Gitignored, holds secrets.** API keys, `JAVA_HOME` / `ANDROID_HOME` / `BUN_INSTALL`, Homebrew, ghcup, cargo, and `PATH` (adds `~/bin`) |
| `.aerospace.toml` | `~/.aerospace.toml` | AeroSpace tiling window manager. `alt-hjkl` focus, `alt-shift-hjkl` move, `alt-1..9` workspaces, `alt-shift-;` service mode. Finder and OrbStack float |
| `.config/nvim/` | `~/.config/nvim` | Neovim with lazy.nvim. See [Neovim](#neovim) |
| `.config/zed/` | `~/.config/zed/settings.json`, `keymap.json` (file links) | Zed with vim mode, Aura Dark theme with a translucent override, keymap that mirrors the Neovim leader bindings |
| `.config/ghostty/config` | `~/.config/ghostty` | Ghostty terminal: black 80% opaque blurred background, hidden titlebar, font size 18 |
| `.config/tmux/tmux.conf` | `~/.config/tmux` | tmux: prefix `Ctrl-a`, 1-based windows, mouse, vi copy mode (`y` copies with `pbcopy`, or `xclip` where `pbcopy` is missing), `prefix hjkl` panes, `prefix f` runs `tmux-sessionizer` |
| `.config/herdr/config.toml` | `~/.config/herdr/config.toml` (file link) | herdr multiplexer: prefix `Ctrl-a`, vim pane focus, `prefix f` / `prefix t` / `prefix T` run the herdr scripts below, sidebar rows show `$idx` numbers |
| `.config/bin/general` | `~/.config/bin` | zsh helpers `addToPath` and `addToPathFront`. Not sourced anywhere at the moment |
| `bin/` | `~/bin` (on `PATH` via `.zshenv`) | Scripts. See [Scripts](#scripts) |
| `lib/herdr_numbering.py` | read by `bin/herdr-*` Python scripts | Shared helpers that rebuild herdr's sidebar order for spaces and agents |
| `launchd/in.ameernoufil.herdr-sidebar-numbers.plist` | `~/Library/LaunchAgents/` (copied, not linked) | Keeps `herdr-sidebar-numbers` running from login, logs to `~/.config/herdr/sidebar-numbers.log` |
| `tests/` | not linked | zsh tests for the two worktree scripts |

## Scripts

| Script | Language | Trigger | What it does |
| --- | --- | --- | --- |
| `sessionizer` | zsh | `Ctrl-F` in the shell | fzf over `~/*`, `~/work/*/*`, `~/personal/*/*`, then asks whether to open the folder in tmux or herdr |
| `tmux-sessionizer` | zsh | `prefix f` in tmux | Creates or switches to a tmux session named after the folder |
| `herdr-sessionizer` | zsh | `prefix f` in herdr | Focuses the herdr workspace for the folder, or creates it. Outside herdr, starts a named session |
| `herdr-worktree-finder` | zsh | `prefix t` in herdr | fzf over the current repo's worktrees (`●` means already open) and focuses or opens one |
| `herdr-worktree-create` | zsh | `prefix shift+t` in herdr | Fetches origin, picks a remote branch with fzf, or `>name` for a new branch from a chosen source, then `herdr worktree create` |
| `herdr-sidebar-numbers` | Python | launchd agent at login | Every 2s stamps each space and agent pane with an `idx` metadata token so the expanded sidebar shows position numbers, which match herdr's `prefix+shift+1..9` agent jump. `--once` runs a single pass |
| `fzf-git.sh` | bash/zsh, sourced | `Ctrl-G` then `Ctrl-F/B/T/R/H/S/L/W/E` | Vendored copy of junegunn/fzf-git.sh (MIT). `Ctrl-G ?` lists the bindings |

`herdr-sidebar-numbers` is also linked from `~/.local/bin/` so herdr can find it without `~/bin` on its `PATH`.

## Neovim

Entry: `init.lua` loads `lua/config/init.lua` (options), `remap.lua` (leader is space) and `lazy.lua` (plugin manager). Plugin versions are pinned in `lazy-lock.json`.

| File | Plugin | Keys |
| --- | --- | --- |
| `config/remap.lua` | none | `<leader>pe` netrw, `<leader>lv` Lazy, `<leader>y` yank to system clipboard |
| `plugins/telescope.lua` | telescope + fzf-native | `<leader>pf` find files, `<leader>pg` live grep |
| `plugins/lsp.lua` | mason, mason-lspconfig, nvim-lspconfig | Installs `lua_ls`, `hls`, `rust_analyzer` (clippy on save, proc macros, inlay hints). On attach: `K` hover, `<leader>la` code action, `<leader>lf` format, `<leader>lr` rename |
| `plugins/treesitter.lua` | nvim-treesitter | Parsers include lua, json, diff, rust |
| `plugins/git.lua` | vim-fugitive | `<leader>gs` |
| `plugins/gitsigns.lua` | gitsigns | none |
| `plugins/undotree.lua` | undotree | `<leader>u` |
| `plugins/theme.lua` | rose-pine | none |
| `plugins/icon.lua` | nvim-web-devicons | none |

## Symlinks

Current links on this machine, recreate them on a new one:

```sh
cd ~
ln -s dotfiles/.zshrc .zshrc
ln -s dotfiles/.zshenv .zshenv
ln -s dotfiles/.zshrc.local .zshrc.local
ln -s dotfiles/.aerospace.toml .aerospace.toml
ln -s dotfiles/bin bin

cd ~/.config
ln -s ../dotfiles/.config/nvim nvim
ln -s ../dotfiles/.config/tmux tmux
ln -s ../dotfiles/.config/ghostty ghostty
ln -s ../dotfiles/.config/bin bin

mkdir -p herdr zed
ln -s ../../dotfiles/.config/herdr/config.toml herdr/config.toml
ln -s ../../dotfiles/.config/zed/settings.json zed/settings.json
ln -s ../../dotfiles/.config/zed/keymap.json zed/keymap.json

mkdir -p ~/.local/bin && cd ~/.local/bin
ln -s ../../dotfiles/bin/herdr-sidebar-numbers herdr-sidebar-numbers

# copied rather than symlinked, launchd is unreliable with symlinked plists
cp ~/dotfiles/launchd/in.ameernoufil.herdr-sidebar-numbers.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/in.ameernoufil.herdr-sidebar-numbers.plist
```

The plist hardcodes `/Users/ameer.noufil` and `/opt/homebrew/bin/python3` (the system `python3` is 3.9 and lacks `tomllib`). Edit both on a machine with a different home or Homebrew prefix.

herdr and zed link single files because those directories also hold logs, sockets, sessions and themes that should stay out of git.

`.zshenv` and `.zshrc.local` are gitignored, so a new machine needs them copied over separately.

## Tests

```sh
zsh tests/herdr-worktree-create.test.zsh
zsh tests/herdr-worktree-finder.test.zsh
```

Both stub `git`, `herdr` and `fzf` as shell functions and source the real script, so they need no repo or herdr server.
