{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    shellInit = ''
      set -gx PATH $PATH /home/parven/.local/bin
      if test -f /home/parven/.config/deepseek/env
        set -gx DEEPSEEK_API_KEY (string split -m 1 '=' (cat /home/parven/.config/deepseek/env))[2]
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
      build = "nh os switch /home/parven/dotfiles";
      clean = "nh clean all";
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      cat = "bat";
    };
  };
}
