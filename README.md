# Pi Nix

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/817160a1-2bdb-43ad-8f6c-73f6815b9d21" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9a3b6a97-38a5-4430-b50d-c210a1b4edc3" />

<h3 align="center">
Dendritic NixOS Config
</h3>

Single flake with Home Manager, stylix, flake-parts, import-tree, and sops-nix. All modules are organized as a tree — drop a `.nix` file in the right folder and it's auto-imported.

---

## Structure

```
dotfiles/
├── flake.nix                    ← flake-parts entry point
├── flake-modules/
│   └── nixos.nix                ← NixOS configuration wiring
├── hardware-configuration.nix
├── config/                      ← kitty, fastfetch, fuzzel, waybar config dirs
├── modules/
│   ├── home/                    ← home-manager modules
│   │   ├── default.nix          ← only imports + home state
│   │   ├── desktop/
│   │   │   ├── gnome/gnome.nix  ← GTK, Qt, dconf, GNOME extensions
│   │   │   └── niri/niri.nix    ← Niri WM with Wayland tooling
│   │   ├── browser/firefox.nix
│   │   ├── editor/vscode.nix
│   │   ├── shell/               ← fish, tmux, kitty, git
│   │   ├── security/            ← ssh, sops
│   │   ├── others/nixcord.nix
│   │   └── core/packages.nix
│   └── nixos/                   ← system modules
│       ├── default.nix          ← only imports + state
│       ├── desktop/
│       │   ├── gnome/gnome.nix  ← GDM, GNOME desktop
│       │   └── niri/niri.nix    ← Niri WM + GDM + Nautilus
│       ├── hardware/            ← nvidia, power, audio, bluetooth
│       ├── core/                ← boot, networking, packages, users
│       ├── services/services.nix  ← printing, flatpak
│       ├── shell/cli-tools.nix    ← nh, starship, direnv
│       ├── theme/stylix.nix
│       ├── gaming/steam.nix
│       ├── media/obs.nix
│       └── virtualization/virtualization.nix  ← podman
├── secrets/
├── sites/                      ← new tab page (Brave homepage)
├── wallpapers/
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
| [nixcord](https://github.com/kaylorben/nixcord) | Equicord Discord mod |
| [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) | Wrapped derivations with embedded config |

## Desktop Switching

Toggle desktop environments by commenting imports in `modules/home/default.nix` and `modules/nixos/default.nix`:

```nix
(inputs.import-tree ./desktop/gnome)    # ← comment to disable GNOME
(inputs.import-tree ./desktop/niri)     # ← comment to disable Niri
```

Each desktop module is self-contained:
- **GNOME** — full GNOME Shell with extensions, GTK/Qt theming, dconf
- **Niri** — Niri WM with GDM, Nautilus, GNOME keyring, Wayland tools (grim, slurp, wlogout), brightness control

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
