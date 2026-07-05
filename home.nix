{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.username = "parven";
  home.homeDirectory = "/home/parven";
  home.stateVersion = "26.05";

  # ------------------------------------------------------------------
  # SSH
  # ------------------------------------------------------------------
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };

  services.ssh-agent.enable = true;

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/home/parven/.config/sops/age/keys.txt";

    secrets."ssh_private_key" = {
      path = "/home/parven/.ssh/id_ed25519";
      mode = "0600";
    };
  };

  # ------------------------------------------------------------------
  # Git
  # ------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      user.name = "Parven05";
      user.email = "parven5@proton.me";
    };
  };

  # ------------------------------------------------------------------
  # Shell
  # ------------------------------------------------------------------
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      zoxide init fish | source
      if test "$TERM" = "xterm-kitty"
        fastfetch
      end
    '';
    shellAliases = {
      # system alias
      btw = "echo i use nixos, btw";
      build = "nh os switch /home/parven/dotfiles";
      clean = "nh clean all";
      # tools alias
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      cat = "bat";
    };
  };

  # ------------------------------------------------------------------
  # tmux
  # ------------------------------------------------------------------

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 10000;
    #keyMode = "vi";
    prefix = "C-a";
    mouse = true;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      set -g terminal-overrides ",xterm-256color:Tc"
    '';
  };

  # ------------------------------------------------------------------
  # GNOME / GTK
  # ------------------------------------------------------------------
  gtk = {
    enable = true;
    iconTheme = {
      name = "Fluent";
      package = pkgs.fluent-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "trayIconsReloaded@selfmade.pl"
        "compiz-alike-magic-lamp-effect@hermes83.github.com"
        "compiz-windows-effect@hermes83.github.com"
        "burn-my-windows@schneegans.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "search-light@icedman.github.com"
        "just-perfection-desktop@just-perfection"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "ideapad@laurento.frittella"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "dash2dock-lite@icedman.github.com"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      overlay-key = "";
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      help = [ ];
    };

    # keybindings
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left = [ "<Alt>q" ];
      switch-to-workspace-right = [ "<Alt>e" ];
      move-to-workspace-left = [ "<Alt>w" ];
      move-to-workspace-right = [ "<Alt>r" ];
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
    };

    # search-light
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = [ "<Alt>a" ];
      border-radius = 7.0;
      border-color = lib.hm.gvariant.mkTuple [
        1.0
        1.0
        1.0
        0.5
      ];
      background-color = lib.hm.gvariant.mkTuple [
        0.0
        0.0
        0.0
        6.0
      ];
    };

    # dash2dock-lite
    "org/gnome/shell/extensions/dash2dock-lite" = {
      open-app-animation = true;
      separator-thickness = 1;
      dock-padding = 1.0;
      edge-distance = 1.0;
      border-radius = 8.0;
      border-thickness = 1;
      border-color = lib.hm.gvariant.mkTuple [
        0.0
        0.0
        0.0
        0.5
      ];
      customize-label = true;
      label-border-radius = 6.0;
      apps-icon = false;
      trash-icon = true;
      downloads-icon = true;
      animation-magnify = 0.20;
      animation-spread = 0.23;
    };

    # just-perfection
    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      quick-settings-airplane-mode = false;
      weather = false;
      events-button = false;
      search = false;
      workspace-popup = false;
      startup-status = 0;
    };

    # auto-move-windows
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "kitty.desktop:1"
        "code.desktop:2"
        "firefox.desktop:3"
        "discord.desktop:4"
      ];
    };

    # compiz-alike-magic-lamp-effect
    "org/gnome/shell/extensions/com/github/hermes83/compiz-alike-magic-lamp-effect" = {
      duration = 225.0;
    };

    # compiz-windows-effect
    "org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect" = {
      friction = 1.5;
      mass = 80.0;
      speedup-factor-divider = 6.0;
      spring-k = 1.0;
    };
  };

  # ------------------------------------------------------------------
  # Home Packages
  # ------------------------------------------------------------------
  home.packages = [
    pkgs.libsecret
    pkgs.git-credential-manager
  ]
  ++ (with pkgs.gnomeExtensions; [
    dash2dock-lite
    auto-move-windows
    ideapad
    just-perfection
    workspace-indicator
    blur-my-shell
    burn-my-windows
    compiz-alike-magic-lamp-effect
    compiz-windows-effect
    search-light
    tray-icons-reloaded
    user-themes
  ]);

  # ------------------------------------------------------------------
  # VS Code
  # ------------------------------------------------------------------
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        pkief.material-icon-theme
        ritwickdey.liveserver
        usernamehw.errorlens
        zhuangtongfa.material-theme
        ziglang.vscode-zig
      ];

      userSettings = {
        "window.menuBarVisibility" = "toggle";
        "workbench.colorTheme" = "Stylix";
        "window.commandCenter" = false;
        "chat.disableAIFeatures" = true;
        "editor.fontSize" = lib.mkDefault 16;
        "workbench.iconTheme" = "material-icon-theme";
        "terminal.external.linuxExec" = "kitty";
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "editor.formatOnSave" = true;
        "task.allowAutomaticTasks" = "on";
      };
    };
  };

  # ------------------------------------------------------------------
  # Firefox
  # ------------------------------------------------------------------
  programs.firefox = {
    enable = true;

    profiles.default = {
      extensions.force = true;

      search = {
        force = true;
        default = "Brave Search";
        engines = {
          "Brave Search" = {
            urls = [
              {
                template = "https://search.brave.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://cdn.search.brave.com/serp/v3/static/brand/6a35a988a9c2d9d5c5b8/favicon-32x32.png";
            definedAliases = [ "@brave" ];
          };
        };
      };
    };

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      DisablePocket = true;
      DisplayBookmarksToolbar = "always";

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
          installation_mode = "force_installed";
        };

        "default-zoom@jamielinux.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/default-zoom/latest.xpi";
          installation_mode = "force_installed";
        };

        "FirefoxColor@mozilla.com" = {
          installation_mode = "force_installed";
        };
      };

      Preferences = {
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
      };
    };
  };

  stylix.targets.firefox = {
    profileNames = [ "default" ];
    colorTheme.enable = true;
    colors.enable = true;
  };

  # ------------------------------------------------------------------
  # Nixcord
  # ------------------------------------------------------------------
  programs.nixcord = {
    enable = true;
    discord.equicord.enable = true;

    config.plugins = {
      hideMedia.enable = true;
    };
  };

  stylix.targets.nixcord = {
    enable = true;
    colors.enable = true;
  };

  # ------------------------------------------------------------------
  # Configs
  # ------------------------------------------------------------------
  home.file.".config/kitty".source = ./config/kitty;
  home.file.".config/fastfetch".source = ./config/fastfetch;
}
