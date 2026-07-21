{ config, pkgs, inputs, ... }: {
  imports = [ inputs.niri.homeModules.niri ];

  home.packages = with pkgs; [
    grim
    slurp
    sway-contrib.grimshot
    wl-clipboard
    wlogout
    brightnessctl
    xwayland-satellite
    swaybg
    networkmanagerapplet
    blueman
    nautilus
  ];

  # GTK theming for native file dialogs and gnome apps
  gtk.enable = true;

  # Secret management for gnome-keyring / libsecret
  services.gnome-keyring.enable = true;

  services.mako.enable = true;
  services.swayidle.enable = true;
  programs.swaylock.enable = true;
  programs.waybar.enable = true;
  services.polkit-gnome.enable = true;
  programs.fuzzel.enable = true;

  stylix.targets.fuzzel = {
    colors.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "16";
    XCURSOR_THEME = "Adwaita";
  };

  programs.niri.settings = {
    outputs."eDP-1".scale = 1.0;

    input.keyboard.xkb.layout = "us";

    prefer-no-csd = true;

    layout = {
      gaps = 16;
      center-focused-column = "never";
      default-column-width = {
        proportion = 1.0;
      };
      focus-ring = {
        width = 2;
        active = { color = "rgba(110, 168, 224, 0.5)"; };
      };
    };

    binds = with config.lib.niri.actions; {
      # Terminal & launcher
      "Mod+T".action = spawn "kitty";
      "Mod+D".action = spawn "fuzzel";

      # Close window & quit
      "Mod+Q".action = close-window;
      "Mod+Shift+Q".action = close-window;
      "Mod+Shift+E".action = quit;

      # Window focus
      "Mod+H".action = focus-column-left;
      "Mod+J".action = focus-window-down;
      "Mod+K".action = focus-window-up;
      "Mod+L".action = focus-column-right;
      "Mod+Left".action = focus-column-left;
      "Mod+Down".action = focus-window-down;
      "Mod+Up".action = focus-window-up;
      "Mod+Right".action = focus-column-right;

      # Move windows
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+J".action = move-window-down;
      "Mod+Shift+K".action = move-window-up;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Down".action = move-window-down;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Right".action = move-column-right;

      # Workspace switching
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;

      # Column / window management
      "Mod+F".action = fullscreen-window;
      "Mod+Shift+F".action = toggle-window-floating;
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = focus-column-left;
      "Mod+Shift+Period".action = focus-column-right;
      "Mod+BracketLeft".action = focus-column-left;
      "Mod+BracketRight".action = focus-column-right;
      "Mod+Minus".action = set-column-width "50%";
      "Mod+Equal".action = reset-window-height;

      # Layout
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;

      # Lock screen
      "Mod+Shift+X".action = spawn "swaylock";

      # Power menu
      "Mod+Shift+W".action = spawn "wlogout";

      # Brightness
      "XF86MonBrightnessUp".action = spawn [ "brightnessctl" "set" "+5%" ];
      "XF86MonBrightnessDown".action = spawn [ "brightnessctl" "set" "5%-" ];

      # Screenshot
      "Print".action = spawn [
        "grimshot"
        "--notify"
        "copy"
        "screen"
      ];
      "Mod+Shift+S".action = spawn [
        "grimshot"
        "--notify"
        "copy"
        "area"
      ];
      "Alt+Print".action = spawn [
        "grimshot"
        "--notify"
        "copy"
        "window"
      ];
    };

    spawn-at-startup = [
      { command = [ "waybar" ]; }
      { command = [ "mako" ]; }
      { command = [ "nm-applet" ]; }
      { command = [ "blueman-applet" ]; }
      {
        command = [
          "swaybg"
          "-i"
          "/home/parven/dotfiles/wallpapers/nix-wallpaper-binary-black_8k.png"
          "-m"
          "fill"
        ];
      }
      {
        command = [
          "swayidle"
          "-w"
          "timeout"
          "300"
          "swaylock"
          "timeout"
          "600"
          "niri"
          "msg"
          "action"
          "power-off-monitors"
          "resume"
          "niri"
          "msg"
          "action"
          "power-on-monitors"
        ];
      }
    ];
  };
}
