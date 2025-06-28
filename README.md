# NixOS-Config
Lenovo IdeaPad Gaming 3 15arh05 - Flake Setup

```
~/.dotfiles
├── flake.lock
├── flake.nix
├── hosts
│   ├── configuration.nix
│   ├── hardware-configuration.nix
│   └── modules
│       ├── audio.nix
│       ├── bootloader.nix
│       ├── pkgs.nix
│       └── extra.nix
└── user
    └── home.nix
```

## **Implementation**
The `.dotfiles` directory separates system-wide settings (`hosts`) from user-specific configurations (`user`).  
Within `hosts`, core system and hardware settings are organized, while the `modules` folder breaks down features like audio, bootloader, and packages into smaller, manageable files.  
