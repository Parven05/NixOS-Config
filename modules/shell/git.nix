# Git configuration — Home Manager

{ config, ... }:
let
  user = config.user.name;
in
{
  home-manager.users.${user}.programs.git = {
    enable = true;
    settings = {
      user.name = "Parven05";
      user.email = "${config.user.email}";
      init.defaultBranch = "main";
      core.editor = "micro";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autosquash = true;
      rebase.autostash = true;
      color.ui = "auto";
    };
  };
}
