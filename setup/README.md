# Bootstrap

Run `setup/mac.sh` once on a fresh Mac (Apple Silicon, user `w`) after cloning this repo to `~/dev/dotfiles-mac-nix`:

```bash
bash setup/mac.sh
```

What the script does:

- fails early if template placeholders (`yourname`, `you@example.com`, ...) ever creep back in
- installs Determinate Nix Installer if needed
- installs Homebrew if needed
- applies the `nix-darwin` + Home Manager configuration (all Homebrew packages, zsh files)
- logs `gh` in if needed, clones the private `ynotzort/dotfiles` stow repo to `~/dotfiles`, and stows `neovim tmux vim wezterm`
- installs a default Node.js version via `fnm` if none is installed yet

It completes in a single run. Right after installing Nix it sources the daemon profile into the current shell, and the first `nix-darwin` activation resolves `nix` by absolute path with the experimental features it needs.

After that, use `rebuild` (`sudo darwin-rebuild switch --flake ~/dev/dotfiles-mac-nix#mac`).

`NIX_DAEMON_PROFILE`, `DARWIN_REBUILD_BIN`, `GH_BIN`, `STOW_BIN` and `FNM_BIN` can be overridden only so the regression test can point the script at sandboxed stubs. Leave them unset for normal use.

## Testing

```bash
bash tests/mac_setup_test.sh
```

Runs the actual script against a PATH-masked sandbox of stub executables, for both a fresh Mac and an already-bootstrapped one, without touching the network, the Nix store, Homebrew, sudo, or system state. See `AGENTS.md` for details.
