# Pi Nix

Personal NixOS configuration. Single flake with Home Manager, flake-parts, and auto-imported modules.

## Components

- **Niri** scrollable-tiling Wayland compositor with **Waybar**
- **Quickshell** custom bar and popup widgets
- **Fuzzel** launcher, **Mako** notifications, **Swaylock** screen lock
- **Awww** animated wallpapers
- **Stylix** Base16 theming across all apps
- **Fish** shell with Starship prompt, **Kitty** terminal, **Tmux**
- **Yazi** file manager, **Fastfetch** system info

## Infrastructure

| Tool | Purpose |
|------|---------|
| [flake-parts](https://flake.parts) | Modular flake framework |
| [Home Manager](https://github.com/nix-community/home-manager) | User environment management |
| [import-tree](https://github.com/denful/import-tree) | Auto-discover `.nix` files |
| [stylix](https://github.com/danth/stylix) | Base16 system-wide theme |
| [sops-nix](https://github.com/Mic92/sops-nix) | Encrypted secrets |
| [disko](https://github.com/nix-community/disko) | Declarative disk partitioning |
| [preservation](https://github.com/nix-community/preservation) | Persistent files across rebuilds |

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
build   # nh os switch /home/parven/dotfiles
clean   # nh clean all
```
