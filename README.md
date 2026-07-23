# Pi Nix

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/817160a1-2bdb-43ad-8f6c-73f6815b9d21" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9a3b6a97-38a5-4430-b50d-c210a1b4edc3" />

<h3 align="center">
Dendritic NixOS Config
</h3>

Single flake with Home Manager, stylix, flake-parts, import-tree, sops-nix, and disko. All modules are organized as a tree — drop a `.nix` file in the right folder and it's auto-imported.

---

## Structure

```
dotfiles/
├── flake.nix                         # flake-parts entry point, all inputs
├── flake-modules/
│   └── nixos.nix                     # NixOS + home-manager wiring
├── hardware-configuration.nix
├── disko.nix                         # declarative disk partitioning
├── config/
│   ├── fastfetch/
│   │   ├── config.jsonc
│   │   └── pi.txt                    # ascii art
│   ├── fuzzel/
│   │   └── fuzzel.ini                # app launcher theme
│   ├── kitty/
│   │   └── kitty.conf
│   └── waybar/
│       ├── color.css                 # dynamic color from wallpaper
│       ├── config.jsonc
│       └── style.css
├── modules/
│   ├── home/                         # home-manager modules
│   │   ├── default.nix               # imports + home state
│   │   ├── browser/
│   │   │   └── helium.nix            # Helium browser (floating PiP)
│   │   ├── core/
│   │   │   ├── features.nix          # feature flags (editor, browser, etc.)
│   │   │   └── packages.nix          # common user packages
│   │   ├── desktop/
│   │   │   └── niri/
│   │   │       ├── niri.nix          # Niri WM + binds + waybar + mako + swaylock
│   │   │       └── scripts/
│   │   │           ├── appdrawer.sh   # fuzzel launcher
│   │   │           ├── bgselector.sh  # wallpaper picker via fuzzel dmenu
│   │   │           ├── colorwaybar.sh # set waybar color from wallpaper brightness
│   │   │           ├── powermenu.sh   # shutdown/reboot/suspend/logout
│   │   │           └── volumeosd.sh   # volume up/down/mute + notify
│   │   ├── editor/
│   │   │   └── vscode.nix            # VS Code
│   │   ├── others/
│   │   │   └── nixcord.nix           # Equicord Discord mod
│   │   ├── security/
│   │   │   ├── sops.nix              # age-encrypted secrets
│   │   │   └── ssh.nix               # SSH config
│   │   └── shell/
│   │       ├── fish.nix              # Fish shell
│   │       ├── git.nix               # Git config
│   │       ├── kitty.nix             # Kitty terminal
│   │       └── tmux.nix              # Tmux
│   └── nixos/                        # system modules
│       ├── default.nix               # imports + state
│       ├── core/
│       │   ├── boot.nix              # systemd-boot, kernel
│       │   ├── features.nix          # system-level feature flags
│       │   ├── impermanence.nix      # root tmpfs + persistent paths
│       │   ├── networking.nix        # NetworkManager
│       │   ├── packages.nix          # system packages
│       │   └── users.nix             # user accounts
│       ├── desktop/
│       │   └── niri/
│       │       └── niri.nix          # GDM + Niri session
│       ├── gaming/
│       │   └── steam.nix
│       ├── hardware/
│       │   ├── audio.nix             # PipeWire
│       │   ├── bluetooth.nix
│       │   ├── nvidia.nix
│       │   └── power.nix             # power profiles, tlp
│       ├── media/
│       │   └── obs.nix
│       ├── services/
│       │   └── services.nix          # printing, flatpak, gnome-keyring
│       ├── shell/
│       │   └── cli-tools.nix         # nh, starship, direnv
│       ├── theme/
│       │   └── stylix.nix            # base16 system-wide theme
│       └── virtualization/
│           └── virtualization.nix    # podman
├── secrets/
│   └── secrets.yaml                  # sops-encrypted (ssh key, API keys)
├── sites/
│   └── index.html                    # custom new tab page
├── wallpapers/
│   ├── eye.png
│   ├── hollow.png
│   ├── mountain.jpg
│   ├── nixos.png
│   ├── space.png
│   └── win.png
└── README.md
```

## Key Tools

| Tool | What it does |
|------|-------------|
| [flake-parts](https://flake.parts) | Modular flake framework |
| [import-tree](https://github.com/denful/import-tree) | Auto-discovers `.nix` files in directories |
| [nh](https://github.com/nix-community/nh) | Build, switch, and auto-clean generations |
| [stylix](https://github.com/danth/stylix) | System-wide base16 dark theme |
| [devenv](https://github.com/cachix/devenv) + [direnv](https://github.com/direnv/direnv) | Declarative dev shells |
| [sops-nix](https://github.com/Mic92/sops-nix) | Age-encrypted secrets |
| [disko](https://github.com/nix-community/disko) | Declarative disk partitioning |
| [impermanence](https://github.com/nix-community/impermanence) | Root tmpfs + persistent paths |
| [nixcord](https://github.com/kaylorben/nixcord) | Equicord Discord mod |
| [Helium](https://github.com/oxcl/nix-flake-helium-browser) | Floating browser with PiP support |

## Desktop Stack

- **WM**: [Niri](https://github.com/YaLTeR/niri) — scrollable-tiling Wayland compositor
- **Bar**: [Waybar](https://github.com/Alexays/Waybar) — dynamic colors from wallpaper
- **Launcher**: [Fuzzel](https://codeberg.org/dnkl/fuzzel) — app launcher + dmenu scripts
- **Notifications**: [Mako](https://github.com/emersion/mako) — grouped, anchored
- **Locker**: [Swaylock](https://github.com/swaywm/swaylock)
- **Wallpaper**: [Awww](https://github.com/nicepkg/awww) — animated transitions
- **Screenshots**: [Grim](https://sr.ht/~emersion/grim/) + [Slurp](https://github.com/emersion/slurp) + [grimshot](https://github.com/OctopusET/sway-contrib)

### Niri Scripts

| Script | Binding | Description |
|--------|---------|-------------|
| `appdrawer` | `Mod+D` | App launcher |
| `bgselector` | `Mod+B` | Pick wallpaper from `~/dotfiles/wallpapers/` |
| `powermenu` | `Mod+P` | Shutdown / reboot / suspend / logout |
| `volumeosd` | media keys | Volume control with OSD notifications |

## Quick Start

```bash
git clone https://github.com/Parven05/Pi-Nix
cd Pi-Nix
sudo nixos-rebuild switch --flake .#nixos
```

Once booted:

```bash
build   # nh os switch /home/parven/dotfiles
clean   # nh clean all
```

---
