<h3 align="center">Pi Nix</h3>

Single flake with Home Manager, stylix, flake-parts, import-tree, sops-nix, and disko. Drop a `.nix` file in the right folder and it's auto-imported.

## Stack

**Niri** scrollable-tiling Wayland compositor, **Waybar** with dynamic wallpaper colors, **Fuzzel** app launcher and dmenu scripts, **Mako** notifications, **Swaylock** screen locker, **Awww** animated wallpapers, **Grim + Slurp** screenshots.

## Key Tools

| Tool | Purpose |
|------|---------|
| [flake-parts](https://flake.parts) | Modular flake framework |
| [import-tree](https://github.com/denful/import-tree) | Auto-discover `.nix` files |
| [nh](https://github.com/nix-community/nh) | Build, switch, clean |
| [stylix](https://github.com/danth/stylix) | Base16 system theme |
| [sops-nix](https://github.com/Mic92/sops-nix) | Encrypted secrets |
| [disko](https://github.com/nix-community/disko) | Declarative disk partitioning |
| [impermanence](https://github.com/nix-community/impermanence) | Root tmpfs + persistent paths |

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
