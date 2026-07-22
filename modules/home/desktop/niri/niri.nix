{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  scriptDir = pkgs.symlinkJoin {
    name = "niri-scripts";
    paths = [
      (pkgs.writeShellScriptBin "appdrawer" ''
        exec ${pkgs.rofi}/bin/rofi -show drun -config "$HOME/.config/rofi/appdrawer.rasi"
      '')
      (pkgs.writeShellScriptBin "bgselector" ''
        wall_dir="$HOME/dotfiles/wallpapers"
        cache_dir="$HOME/.cache/thumbnails/bgselector"

        mkdir -p "$wall_dir"
        mkdir -p "$cache_dir"

        # Generate thumbnails
        find "$wall_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | while read -r imagen; do
          filename="$(basename "$imagen")"
          thumb="$cache_dir/$filename"
          if [ ! -f "$thumb" ]; then
            ${pkgs.imagemagick}/bin/magick convert -strip "$imagen" -thumbnail x540^ -gravity center -extent 262x540 "$thumb"
          fi
        done

        # List wallpapers with icons for rofi
        wall_selection=$(ls "$wall_dir" | while read -r A; do echo -en "$A\x00icon\x1f$cache_dir/$A\n"; done | ${pkgs.rofi}/bin/rofi -dmenu -config "$HOME/.config/rofi/bgselector.rasi")

        # Set wallpaper and update waybar color
        if [ -n "$wall_selection" ]; then
          ${pkgs.awww}/bin/awww img "$wall_dir/$wall_selection" -t grow --transition-duration 1 --transition-fps 75
          sleep 0.2
          colorwaybar "$wall_dir/$wall_selection"
          exit 0
        else
          exit 1
        fi
      '')
      (pkgs.writeShellScriptBin "colorwaybar" ''
        image="$1"
        waybar_css="$HOME/.config/waybar/color.css"

        touch "$waybar_css"

        # Calculate brightness
        brightness=$(${pkgs.imagemagick}/bin/convert "$image" -resize 500x500^ -format "%[fx:int(mean*100)]" info:)
        if (( brightness < 48 )); then
            color="rgba(255,255,255,0.8)"
        else
            color="rgba(0,0,0,0.8)"
        fi

        # Write color to css
        echo "@define-color primary $color;" > "$waybar_css"
      '')

      (pkgs.writeShellScriptBin "powermenu" ''
        shutdown="Shutdown"
        reboot="Reboot"
        suspend="Suspend"
        logout="Logout"

        chosen="$(printf '%s\0icon\x1f%s\n%s\0icon\x1f%s\n%s\0icon\x1f%s\n%s\0icon\x1f%s\n' \
          "$shutdown" "system-shutdown" \
          "$reboot" "system-reboot" \
          "$suspend" "system-suspend" \
          "$logout" "system-log-out" | ${pkgs.rofi}/bin/rofi -dmenu -config "$HOME/.config/rofi/powermenu.rasi")"

        case "$chosen" in
          "$shutdown") ${pkgs.systemd}/bin/poweroff ;;
          "$reboot")   ${pkgs.systemd}/bin/reboot ;;
          "$suspend")  ${pkgs.systemd}/bin/systemctl suspend ;;
          "$logout")   ${pkgs.niri}/bin/niri msg action quit ;;
          *)           exit 0 ;;
        esac
      '')
      (pkgs.writeShellScriptBin "volumeosd" ''
        step=0.01

        case "$1" in
            up)
                ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ 0
                ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ "''${step}+"
                ;;
            down)
                ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ 0
                ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ "''${step}-"
                ;;
            mute)
                ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle
                ;;
        esac

        volume=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_SINK@)
        vol_value=$(echo "$volume" | awk '{print $2 * 100}')
        vol_status=$(echo "$volume" | cut -d" " -f3)

        if [ "$vol_status" = "[MUTED]" ]; then
            ${pkgs.libnotify}/bin/notify-send -a "muted" -h int:value:"$vol_value" ""
            exit 0
        fi

        ${pkgs.libnotify}/bin/notify-send -a "volume" -h int:value:"$vol_value" ""
      '')
    ];
  };
in
{
  imports = [ inputs.niri.homeModules.niri ];
}
// mkIf (config.my.desktop == "niri" || config.my.desktop == "both") {
  home.packages = with pkgs; [
    # screenshot
    grim
    slurp
    sway-contrib.grimshot
    wl-clipboard

    # hardware
    brightnessctl
    pavucontrol
    playerctl

    # wayland support
    xwayland-satellite

    # status bar (replaces ashell)
    waybar

    # wallpaper daemon (replaces swaybg)
    awww

    # app launcher (replaces fuzzel)
    rofi

    # wallpaper selector
    imagemagick

    # cursor theme
    bibata-cursors

    # icon theme
    fluent-icon-theme

    # custom scripts
    scriptDir
  ];

  gtk.enable = true;
  gtk.iconTheme = lib.mkForce {
    name = "Fluent";
    package = pkgs.fluent-icon-theme;
  };
  gtk.cursorTheme = {
    name = "Bibata-Original-Classic";
    package = pkgs.bibata-cursors;
  };

  services.gnome-keyring.enable = true;

  services.mako = lib.mkForce {
    enable = true;
    font = "JetBrainsMono Nerd Font 10";
    backgroundColor = "#080808e6";
    borderRadius = 8;
    borderSize = 0;
    extraConfig = ''
      [app-name=volume]
      anchor=bottom-center
      group-by=app-name
      format=<b>%s</b>\n%b
      width=200
      border-size=28
      border-radius=14
      border-color=#000000e6
      background-color=#323232ff
      progress-color=source #ffffffff
      outer-margin=0,0,20,0
      padding=1
      layer=overlay
      default-timeout=1000

      [app-name=muted]
      anchor=bottom-center
      group-by=app-name
      format=<b>%s</b>\n%b
      width=200
      border-size=28
      border-radius=14
      border-color=#00000080
      background-color=#32323280
      progress-color=source #ffffff80
      outer-margin=0,0,20,0
      padding=1
      layer=overlay
      default-timeout=1000

      [anchor=bottom-center]
      max-visible=1

      [hidden=true]
      invisible=1
    '';
  };

  services.swayidle.enable = true;
  programs.swaylock.enable = true;

  services.swayidle.events = [
    {
      event = "before-sleep";
      command = "${pkgs.swaylock}/bin/swaylock -f";
    }
  ];

  # Systemd services for wallpaper daemon and overview listener
  systemd.user.services.awww = {
    Unit = {
      Description = "Wallpaper daemon for awww";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  xdg.configFile."waybar/config.jsonc" = {
    source = ../../../../config/waybar/config.jsonc;
  };
  xdg.configFile."waybar/style.css" = {
    source = ../../../../config/waybar/style.css;
  };
  xdg.configFile."waybar/color.css" = {
    source = ../../../../config/waybar/color.css;
  };

  xdg.configFile."rofi/appdrawer.rasi" = {
    source = ../../../../config/rofi/appdrawer.rasi;
  };
  xdg.configFile."rofi/bgselector.rasi" = {
    source = ../../../../config/rofi/bgselector.rasi;
  };
  xdg.configFile."rofi/powermenu.rasi" = {
    source = ../../../../config/rofi/powermenu.rasi;
  };
  xdg.configFile."rofi/themes/appdrawer.rasi" = {
    source = ../../../../config/rofi/themes/appdrawer.rasi;
  };
  xdg.configFile."rofi/themes/bgselector.rasi" = {
    source = ../../../../config/rofi/themes/bgselector.rasi;
  };
  xdg.configFile."rofi/themes/powermenu.rasi" = {
    source = ../../../../config/rofi/themes/powermenu.rasi;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Original-Classic";
  };

  programs.niri.settings = {
    outputs = {
      "eDP-1".scale = 1.0;
      "HDMI-A-1".scale = 1.0;
    };

    input = {
      keyboard.xkb.layout = "us";
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
      focus-follows-mouse = {
        max-scroll-amount = "0%";
      };
    };

    prefer-no-csd = true;

    layout = {
      gaps = 0;
      center-focused-column = "never";
      default-column-width = {
        proportion = 0.5;
      };
      focus-ring = {
        enable = false;
      };
      border = {
        enable = false;
      };
      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = "#0007";
      };
      background-color = "transparent";
    };

    cursor = {
      theme = "Bibata-Original-Classic";
      hide-after-inactive-ms = 3000;
    };

    gestures = {
      hot-corners = {
        enable = false;
      };
    };

    overview = {
      workspace-shadow = {
        enable = false;
      };
    };

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    layer-rules = [
      {
        matches = [
          { namespace = "^awww-daemon$"; }
        ];
        place-within-backdrop = true;
      }
    ];

    window-rules = [
      {
        matches = [
          { app-id = "^org\\.wezfurlong\\.wezterm$"; }
        ];
        default-column-width = { };
      }
      {
        matches = [
          { app-id = "^firefox$"; }
          { title = "^Picture-in-Picture$"; }
        ];
        open-floating = true;
      }
      {
        matches = [
          { app-id = "^org\\.mozilla\\.firefox$"; }
        ];
        open-fullscreen = false;
      }
    ];

    binds = with config.lib.niri.actions; {
      # Terminal & app launcher
      "Mod+T".action = spawn "kitty";
      "Mod+D".action = spawn "appdrawer";
      "Mod+P".action = spawn "powermenu";
      "Mod+B".action = spawn "bgselector";

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
      "Mod+Ctrl+H".action = move-column-left;
      "Mod+Ctrl+J".action = move-window-down;
      "Mod+Ctrl+K".action = move-window-up;
      "Mod+Ctrl+L".action = move-column-right;
      "Mod+Ctrl+Left".action = move-column-left;
      "Mod+Ctrl+Down".action = move-window-down;
      "Mod+Ctrl+Up".action = move-window-up;
      "Mod+Ctrl+Right".action = move-column-right;

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
      "Mod+Period".action = expel-window-from-column;
      "Mod+Shift+Period".action = focus-column-right;
      "Mod+BracketLeft".action = consume-or-expel-window-left;
      "Mod+BracketRight".action = consume-or-expel-window-right;
      "Mod+Minus".action = set-column-width "50%";
      "Mod+Equal".action = reset-window-height;

      # Layout
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;

      # Lock screen
      "Mod+Shift+X".action = spawn "swaylock";
      "Super+Alt+L".action = spawn "swaylock";

      # Brightness
      "XF86MonBrightnessUp".action = spawn [
        "brightnessctl"
        "set"
        "+5%"
      ];
      "XF86MonBrightnessDown".action = spawn [
        "brightnessctl"
        "set"
        "5%-"
      ];

      # Volume (using volumeosd script matching reference)
      "XF86AudioRaiseVolume" = {
        action = spawn "volumeosd" "up";
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        action = spawn "volumeosd" "down";
        allow-when-locked = true;
      };
      "XF86AudioMute" = {
        action = spawn "volumeosd" "mute";
        allow-when-locked = true;
      };
      "XF86AudioMicMute" = {
        action = spawn-sh "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        allow-when-locked = true;
      };

      # Media keys
      "XF86AudioPlay".action = spawn-sh "playerctl play-pause";
      "XF86AudioPause".action = spawn-sh "playerctl play-pause";
      "XF86AudioStop".action = spawn-sh "playerctl stop";
      "XF86AudioPrev".action = spawn-sh "playerctl previous";
      "XF86AudioNext".action = spawn-sh "playerctl next";

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

      # Navigation extras
      "Mod+Tab".action = focus-workspace-previous;
      "Mod+U".action = focus-workspace-down;
      "Mod+I".action = focus-workspace-up;
      "Mod+Home".action = focus-column-first;
      "Mod+End".action = focus-column-last;

      # Move workspace
      "Mod+Shift+U".action = move-workspace-up;
      "Mod+Shift+I".action = move-workspace-down;

      # Move column to first/last
      "Mod+Ctrl+Home".action = move-column-to-first;
      "Mod+Ctrl+End".action = move-column-to-last;

      # Monitor focus
      "Mod+Shift+Left".action = focus-monitor-left;
      "Mod+Shift+Right".action = focus-monitor-right;
      "Mod+Shift+Up".action = focus-monitor-up;
      "Mod+Shift+Down".action = focus-monitor-down;

      # Window management
      "Mod+M".action = maximize-column;
      "Mod+W".action = toggle-column-tabbed-display;
      "Mod+V".action = toggle-window-floating;
      "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

      "Mod+C".action = center-column;
      "Mod+Ctrl+C".action = center-visible-columns;
      "Mod+Ctrl+F".action = expand-column-to-available-width;
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      # Overview & hotkey help
      "Mod+O".action = toggle-overview;
      "Mod+Shift+Slash".action = show-hotkey-overlay;

      # Power off monitors & inhibit
      "Mod+Shift+P".action = power-off-monitors;
      "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;

      # Scroll wheel workspace switching
      "Mod+WheelScrollDown" = {
        action = focus-workspace-down;
        cooldown-ms = 150;
      };
      "Mod+WheelScrollUp" = {
        action = focus-workspace-up;
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollDown" = {
        action = move-column-to-workspace-down;
        cooldown-ms = 150;
      };
      "Mod+Ctrl+WheelScrollUp" = {
        action = move-column-to-workspace-up;
        cooldown-ms = 150;
      };

    };

    spawn-at-startup = [
      { command = [ "waybar" ]; }
      { command = [ "mako" ]; }
      {
        command = [
          "bash"
          "-c"
          "sleep 2 && bluetoothctl power on"
        ];
      }
      {
        command = [
          "bash"
          "-c"
          "sleep 1 && ${pkgs.awww}/bin/awww img \"$HOME/dotfiles/wallpapers/$(ls $HOME/dotfiles/wallpapers | head -1)\" -t grow --transition-duration 1 --transition-fps 75"
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
