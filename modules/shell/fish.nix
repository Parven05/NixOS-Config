# Fish shell — NixOS enable + Home Manager configuration

{
  config,
  pkgs,
  ...
}:
let
  user = config.user.name;
in
{
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  home-manager.users.${user}.programs.fish = {
    enable = true;
    shellInit = ''
      set -gx PATH $PATH /home/${user}/.local/bin
      if test -f /home/${user}/.config/deepseek/env
        set -gx DEEPSEEK_API_KEY (string split -m 1 '=' (cat /home/${user}/.config/deepseek/env))[2]
      end
    '';
    interactiveShellInit = ''
      zoxide init fish | source
      if test "$TERM" = "xterm-kitty"
        fastfetch
      end
    '';
    shellAliases = {
      btw = "echo i use nixos, btw";
      build = "nh os switch /home/${user}/Pi-Nix";
      clean = "nh clean all";
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      cat = "bat";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "rg";
    };
  };
}
