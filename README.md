# Pi Nix

Personal NixOS configuration. Single flake with Home Manager, flake-parts, and auto-imported modules.

## Components

- **Niri** scrollable-tiling Wayland compositor with **Waybar**
- **Quickshell** custom bar and popup widgets (Qt/QML)
- **Fuzzel** launcher, **Mako** notifications
- **Awww** animated wallpapers
- **Stylix** Base16 theming across all apps
- **Fish** shell with **Starship** prompt, **Kitty** terminal, **Tmux**
- **Yazi** file manager, **Fastfetch** system info
- **Helium** Chromium-based browser with uBlock Origin
- **Podman** + **Distrobox** containers
- **Flatpak** desktop apps, **CUPS** printing
- **Steam** + **gamemode** + **gamescope** gaming
- **OBS Studio** media capture
- **NVIDIA** PRIME offload

## Flake Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| [nixpkgs](https://github.com/nixos/nixpkgs) | `nixos-unstable` | Package collection |
| [home-manager](https://github.com/nix-community/home-manager) | `nix-community` | User environment management |
| [flake-parts](https://flake.parts) | `hercules-ci` | Modular flake framework |
| [import-tree](https://github.com/denful/import-tree) | `denful` | Auto-discover `.nix` files |
| [pkgs-by-name-for-flake-parts](https://github.com/drupol/pkgs-by-name-for-flake-parts) | `drupol` | `pkgs/by-name` directory structure |
| [stylix](https://github.com/danth/stylix) | `danth` | Base16 system-wide theming |
| [sops-nix](https://github.com/Mic92/sops-nix) | `Mic92` | Encrypted secrets (age) |
| [niri-flake](https://github.com/sodiboo/niri-flake) | `sodiboo` | Niri compositor |
| [nix-flake-helium-browser](https://github.com/oxcl/nix-flake-helium-browser) | `oxcl` | Helium browser |
| [disko](https://github.com/nix-community/disko) | `nix-community` | Declarative disk partitioning |
| [preservation](https://github.com/nix-community/preservation) | `nix-community` | Persistent files across rebuilds |
| [quickshell](https://git.outfoxxed.me/outfoxxed/quickshell) | `outfoxxed` | Qt/QML shell framework |
| [qml-niri](https://github.com/imiric/qml-niri) | `imiric` | Niri IPC bindings for Quickshell |

## Nix Tooling

| Tool | Purpose |
|------|---------|
| [nh](https://github.com/viperML/nh) | NixOS rebuild & GC helper |
| [nix-tree](https://github.com/utdemir/nix-tree) | Interactive dependency browser |
| [nixfmt](https://github.com/NixOS/nixfmt) | Official Nix formatter |
| [nix-direnv](https://github.com/nix-community/nix-direnv) | Per-directory dev environments |
| [devenv](https://devenv.sh) | Reproducible dev environments |
| [home-manager](https://github.com/nix-community/home-manager) | Dotfile & user package management |
| [sops](https://github.com/getsops/sops) | Secrets encryption/decryption |

## Feature Flags

Toggle in `modules/default.nix`: desktop, gaming, media, virtualization, bluetooth, nvidia.

## Quick Start

```bash
git clone https://github.com/Parven05/Pi-Nix
cd Pi-Nix
sudo nixos-rebuild switch --flake .#nixos
```

Once booted:

```bash
build   # nh os switch /home/parven/Pi-Nix
clean   # nh clean all
```
