# Putting My Mac Setup Into Code

My Mac had drifted into the usual state: about a hundred Homebrew packages, a 450-line `.zshrc`, a stow repo for editor config, and a handful of apps dragged into `/Applications` by hand.
None of it was written down anywhere I could replay on a new machine.

I started from [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix), a small public Nix setup with a [good write-up](https://open.substack.com/pub/kunchenguid/p/how-i-built-a-reproducible-mac-setup), and rewrote it until it described my machine instead of someone else's.

## The stack

- **[Nix](https://nixos.org/)** (via the Determinate installer) as the foundation
- **[nix-darwin](https://github.com/nix-darwin/nix-darwin)** for machine-level config: macOS defaults, the user account, and Homebrew
- **[Home Manager](https://github.com/nix-community/home-manager)** for the home directory: git, and symlinks to my shell files
- **Declarative [Homebrew](https://brew.sh/)** for nearly every app and CLI tool
- **[GNU stow](https://www.gnu.org/software/stow/)** for my existing [dotfiles repo](https://github.com/ynotzort/dotfiles) (nvim, tmux, vim, wezterm), which I didn't want to migrate

That is less Nix than a purist would like. Most packages come from Homebrew, not nixpkgs.
That's on purpose: everything was already installed through brew, and nix-darwin's `homebrew` module turns the list into code without changing how anything is installed.

## Taking inventory

The first step was finding out what I'd actually installed: `brew leaves` for formulas, `brew list --cask` for casks, `ls /Applications` for everything else, plus the other package managers (fnm, npm globals, cargo, uv).

Then I went through it item by item and decided what belongs in the setup.
A few things came out of that:

- **Apps installed by hand can be casks too.** Obsidian, Slack, Chrome, Zed, Tailscale and a dozen others are now in the cask list. On the existing machine they have to be adopted once with `brew install --cask --adopt ...`, or brew refuses to overwrite them.
- **The template's defaults weren't mine.** It shipped a package list, fonts, a starship prompt, git aliases and key-repeat settings. I removed every one I don't actually use. The macOS defaults that stayed are the ones my machine already had.
- **Cleanup mode matters.** The template used `onActivation.cleanup = "zap"`, which uninstalls anything not in the list on every rebuild. I switched to `"none"` until I trust the list.

## Shell config as plain files

My zsh setup uses zap for plugins, powerlevel10k for the prompt, and a long custom atuin + fzf history widget.
Rewriting all of that as Home Manager's `programs.zsh` options would be a lot of work for no gain, so the files live in `files/zsh/` and Home Manager symlinks them into `~` with `mkOutOfStoreSymlink`.
Edits in the repo take effect immediately, with no rebuild.

The only changes needed for a fresh machine were:

- clone zap if it isn't there yet
- guard `. ~/.cargo/env` so it doesn't fail before rustup has run
- use `$HOME` instead of hard-coded `/Users/...` paths

## The bootstrap

`setup/mac.sh` takes a new Mac from nothing to done in one run:

1. Install Nix and source its daemon profile in the same shell
2. Install Homebrew
3. Activate nix-darwin for the first time with `nix run nix-darwin/master#darwin-rebuild`, which also installs every Homebrew package
4. Log `gh` in, clone the private stow repo, and `stow neovim tmux vim wezterm`
5. Install the LTS Node.js with `fnm`

A script that installs Nix and activates a whole system is not something to test by running it.
The repo has a test harness that runs the real script against stub `curl`, `nix`, `sudo`, `gh`, `stow` and `fnm` executables in a temp sandbox, and checks that every step ran exactly once.

## Day to day

After that it's: edit `nix/host.nix`, run `rebuild`.
If I `brew install` something by hand, I add it to the list, or the next Mac won't have it.
Not perfect, but now the list exists, and it's in git.
