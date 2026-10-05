#!/bin/bash

set -euo pipefail

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )

# Fail early if placeholder values have not been customized yet
if grep -R -n -E 'yourname|/Users/yourname|Your Name|you@example.com' \
  "$DOTFILES_DIR/flake.nix" \
  "$DOTFILES_DIR/nix" >/dev/null 2>&1; then
  echo "Placeholder values are still present in the repo."
  echo "Please replace values like 'yourname', '/Users/yourname', 'Your Name', and 'you@example.com' before running setup/mac.sh."
  exit 1
fi

# Install Nix via Determinate if missing
if ! command -v nix &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  # The installer wires Nix into new shells, but this script is still running
  # in the shell that started before Nix existed. Source the daemon profile
  # now so `nix` works for the rest of this run instead of needing a second
  # session. The profile script isn't written to be `set -u` safe, so relax
  # that guard just around the source. (Overridable so tests can point at a
  # sandboxed profile instead of the real one.)
  : "${NIX_DAEMON_PROFILE:=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh}"
  if [ -f "$NIX_DAEMON_PROFILE" ]; then
    set +u
    # shellcheck disable=SC1090
    . "$NIX_DAEMON_PROFILE"
    set -u
  fi
fi

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apply the Nix configuration. (DARWIN_REBUILD_BIN is overridable so tests
# can point at a sandboxed binary instead of the real one.)
: "${DARWIN_REBUILD_BIN:=/run/current-system/sw/bin/darwin-rebuild}"
if [ -x "$DARWIN_REBUILD_BIN" ]; then
  sudo "$DARWIN_REBUILD_BIN" switch --flake "$DOTFILES_DIR#mac"
else
  # First activation: nix-darwin has never run, so darwin-rebuild doesn't
  # exist yet and has to be fetched via `nix run`. Resolve nix by absolute
  # path since sudo won't inherit the PATH this script just sourced, and
  # enable the experimental features it needs in case nix.conf doesn't
  # already have them.
  NIX_BIN=$(command -v nix || echo /nix/var/nix/profiles/default/bin/nix)
  sudo "$NIX_BIN" --extra-experimental-features "nix-command flakes" \
    run nix-darwin/master#darwin-rebuild -- switch --flake "$DOTFILES_DIR#mac"
fi

# Clone the (private) stow dotfiles and link nvim, tmux, vim, wezterm into
# $HOME. gh and stow come from Homebrew; gh's clone uses the Command Line
# Tools git that the Homebrew installer set up. (Overridable so tests can
# point at stubs.)
: "${GH_BIN:=/opt/homebrew/bin/gh}"
: "${STOW_BIN:=/opt/homebrew/bin/stow}"
STOW_DIR="$HOME/dotfiles"
if [ ! -d "$STOW_DIR" ]; then
  "$GH_BIN" auth status >/dev/null 2>&1 || "$GH_BIN" auth login --git-protocol https --web
  "$GH_BIN" repo clone ynotzort/dotfiles "$STOW_DIR"
fi
"$STOW_BIN" -d "$STOW_DIR" -t "$HOME" neovim tmux vim wezterm

# Install a default Node.js via fnm (a Homebrew brew in nix/host.nix) if none
# is installed yet. (FNM_BIN is overridable so tests can point at a stub.)
: "${FNM_BIN:=/opt/homebrew/bin/fnm}"
if [ -x "$FNM_BIN" ] && ! "$FNM_BIN" list | grep -q default; then
  "$FNM_BIN" install --lts
fi

echo "Bootstrap complete. Restart your shell if needed, then use 'rebuild' or darwin-rebuild for future config changes."
