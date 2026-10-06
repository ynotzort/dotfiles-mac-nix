# dotfiles-mac-nix

My Mac setup, in code: [Nix](https://nixos.org/), [`nix-darwin`](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and declarative [Homebrew](https://brew.sh/).
One script turns a fresh Mac into my machine.

Started from [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix), then rewritten to match what I actually run.

## What lives where

- `nix/host.nix` - every Homebrew formula, cask, and tap I use, plus macOS defaults (dark mode, no autocorrect, Finder path bar, tap to click, Dock autohide)
- `nix/user.nix` - Home Manager: git + LFS, and symlinks for the zsh files below
- `files/zsh/` - my zsh setup (zap plugins, powerlevel10k, atuin + fzf history search, zoxide, fnm), linked into `~` so edits here are live
- [`ynotzort/dotfiles`](https://github.com/ynotzort/dotfiles) (private, GNU stow) - nvim, tmux, vim, wezterm; cloned and stowed by the bootstrap script
- `setup/mac.sh` - fresh-Mac bootstrap
- `tests/` - sandboxed regression test for the bootstrap script

Not here: secrets, machine-local config (`~/.zshrc.local` is sourced if present, never committed), and the git identity, which stays in `~/.gitconfig` for now.

## New Mac

Assumes Apple Silicon. Works for any macOS username: the flake reads it from the environment (hence `--impure`).

```bash
git clone https://github.com/ynotzort/dotfiles-mac-nix.git ~/dev/dotfiles-mac-nix
bash ~/dev/dotfiles-mac-nix/setup/mac.sh
```

In one run, the script:

1. installs Nix (Determinate installer) and Homebrew
2. activates nix-darwin + Home Manager, which installs every Homebrew package and links the zsh files
3. logs `gh` in (browser), clones `ynotzort/dotfiles` to `~/dotfiles`, and stows `neovim tmux vim wezterm`
4. installs the LTS Node.js via `fnm`

Open a new terminal afterwards. zsh clones zap and its plugins on first start.

## Day to day

Edit the config, then:

```bash
rebuild   # sudo darwin-rebuild switch --flake ~/dev/dotfiles-mac-nix#mac --impure
```

Installed something with `brew install`? Add it to `nix/host.nix` too, or the next Mac won't have it.
Homebrew cleanup is `"none"`, so a rebuild never uninstalls anything that's missing from the list.
Switch it to `"zap"` once the list is complete if you want it enforced.

Where things go:

- GUI apps and most CLI tools: Homebrew in `nix/host.nix`
- shell config: `files/zsh/`
- editor and terminal config: the stow repo
- language toolchains: their own managers (fnm, uv, rustup, rbenv)

## Testing the bootstrap

Never run `setup/mac.sh` on an already set-up machine just to try it. Use:

```bash
bash tests/mac_setup_test.sh
```

It runs the real script against stub executables in a temp sandbox and covers both a fresh Mac and an already-bootstrapped one. See `AGENTS.md` for details.
