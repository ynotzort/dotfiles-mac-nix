{ config, user, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dev/dotfiles-mac-nix";
  link = f: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/zsh/${f}";
in
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "23.11";
  home.language.base = "en_US.UTF-8";

  # Identity stays in ~/.gitconfig until personal vs work is decided.
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # zsh is plain files (zap + powerlevel10k), not programs.zsh; edits in the repo are live.
  home.file = {
    ".zshrc".source = link "zshrc";
    ".zprofile".source = link "zprofile";
    ".zshenv".source = link "zshenv";
    ".p10k.zsh".source = link "p10k.zsh";
  };
}
