# Pi Nix

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/817160a1-2bdb-43ad-8f6c-73f6815b9d21" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9a3b6a97-38a5-4430-b50d-c210a1b4edc3" />

<h3 align="center">
Opinionated NixOS Flake Config
</h3>

Single flake with Home Manager, stylix, and sops-nix. All modules in `modules/nixos/` and `modules/home/`.

---

## Structure

```
dotfiles/
├── flake.nix
├── flake.lock
├── hardware-configuration.nix
├── config/kitty/
├── config/fastfetch/
├── modules/
│   ├── nixos/    (stylix, cli-tools, nix-core, and hardware config)
│   └── home/     (fish, tmux, git, ssh, gnome, vscode, firefox, nixcord, sops)
├── secrets/secrets.yaml
├── wallpapers/
└── README.md
```

## Nix Tooling

| Tool | What it does |
|------|-------------|
| [nh](https://github.com/nix-community/nh) | Build, switch, and auto-clean generations (keep 4d or 3 gens) |
| [stylix](https://github.com/danth/stylix) | System wide base16 dark theme, applies to kitty, fastfetch, btop, GTK, Firefox, Discord |
| [direnv](https://github.com/direnv/direnv) + nix-direnv | Cached per-directory dev shells from flake |
| [nixfmt](https://github.com/NixOS/nixfmt) | Nix formatter |
| [sops-nix](https://github.com/Mic92/sops-nix) | Age-encrypted secrets decrypted at boot (SSH key, DeepSeek API key) |
| [nixcord](https://github.com/kaylorben/nixcord) | Equicord Discord mod with stylix theming |
| [starship](https://starship.rs/) | Minimal prompt, no blank line |

---

## Quick Start

```bash
git clone https://github.com/Parven05/dotfiles /home/user/dotfiles
cd /home/user/dotfiles
sudo nixos-rebuild switch --flake .#nixos
```

Once booted into the new system, use the aliases:

```bash
build   # nh os switch /home/user/dotfiles
clean   # nh clean all
```

---
