# Pi Nix

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/817160a1-2bdb-43ad-8f6c-73f6815b9d21" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9a3b6a97-38a5-4430-b50d-c210a1b4edc3" />

<h3 align="center">
Opinionated NixOS Flake Config
</h3>


# Usage

- **[nh](https://github.com/nix-community/nh)** = rebuild / clean CLI wrapper, aliased to `build`/`clean`
- **[fish](https://github.com/fish-shell/fish-shell)** = default shell, with zoxide, fastfetch, eza, bat
- **[Home Manager](https://wiki.nixos.org/wiki/Home_Manager)** = per-user configs, symlinks kitty / fastfetch dotfiles
- **[stylix](https://github.com/danth/stylix)** = system-wide base16 dark theme
- **[direnv](https://github.com/direnv/direnv)** = cached per-directory dev shells
- **[nixfmt](https://github.com/NixOS/nixfmt)** = Nix file formatter (needs editor hookup)
- **[starship](https://starship.rs/)** = minimal shell prompt

## [nh](https://github.com/nix-community/nh)
```nix
programs.nh = {
  enable = true;
  clean.enable = true;
  clean.extraArgs = "--keep-since 4d --keep 3";
  flake = "/home/parven/dotfiles";
};
```
Sets the flake path in `configuration.nix` so `nh os switch` needs no args, and auto cleans old generations, keeping the last 4 days or 3 generations. Aliased as `build` and `clean` in fish.

<img width="1195" height="658" alt="nh rebuild" src="https://github.com/user-attachments/assets/bd55db83-79ff-4adb-8885-de4dd7ff5d0c" />

## [fish](https://github.com/fish-shell/fish-shell)
```nix
programs.fish.enable = true;
users.users.parven.shell = pkgs.fish;
```
```nix
programs.fish = {
  enable = true;
  interactiveShellInit = ''
    zoxide init fish | source
    if test "$TERM" = "xterm-kitty"
      fastfetch
    end
  '';
  shellAliases = {
    build = "nh os switch /home/parven/dotfiles";
    clean = "nh clean all";
    ls = "eza --icons --group-directories-first";
    cat = "bat";
  };
};
```
Enabled system wide as the default shell, then configured per user with [zoxide](https://github.com/ajeetdsouza/zoxidehttps://github.com/ajeetdsouza/zoxide) init, fastfetch on Kitty launch, and [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat) aliases.

<img width="1195" height="658" alt="fish shell" src="https://github.com/user-attachments/assets/fb14f7a7-1c0f-4480-aed3-184d4be4e9d2" />

## [Home Manager](https://wiki.nixos.org/wiki/Home_Manager)
```nix
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
  users.parven = import ./home.nix;
  backupFileExtension = "backup";
};
```
```nix
home.file.".config/kitty".source = ./config/kitty;
home.file.".config/fastfetch".source = ./config/fastfetch;
```
Shares the system `pkgs` for faster builds and safer rebuilds. `home.nix` sets git identity and symlinks kitty and fastfetch configs into `~/.config`.

## [stylix](https://github.com/danth/stylix)
```nix
stylix.enable = true;
stylix.image = ./wallpapers/nix-wallpaper-binary-black_8k.png;
stylix.polarity = "dark";
stylix.base16Scheme = {
  base00 = "111418";
  base05 = "c9d1d9";
  base0D = "6ea8e0";
  # ...
};
```
Applies a custom base16 dark scheme system wide to every Stylix aware app. Kitty, fastfetch, and btop are themed through Stylix targets.

<img width="1920" height="1080" alt="stylix theme" src="https://github.com/user-attachments/assets/17be5da8-83ac-46d3-83a5-5329566a958d" />

## [direnv](https://github.com/direnv/direnv)
```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```
Caches flake dev shell evaluations per directory so `cd` into a project doesn't re-evaluate the whole shell every time.

## [nixfmt](https://github.com/NixOS/nixfmt)
```nix
environment.systemPackages = with pkgs; [
  nixfmt
  vscode
];
```
Installed as a package but needs an editor extension to hook it up. For VSCode, install [Nix IDE](https://github.com/nix-community/vscode-nix-ide)
For other editors like Neovim, see [this](https://github.com/NixOS/nixfmt#neovim--nixd).

<img width="701" height="681" alt="image" src="https://github.com/user-attachments/assets/aef4b164-3ae9-4628-9833-6102fac57d87" />

Formatter and syntax highlighting for editing Nix files.

## [starship](https://starship.rs/)
```nix
programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    line_break.disabled = true;
  };
};
```
Minimal prompt config, no leading blank line or line break before the prompt.

<img width="1195" height="119" alt="starship prompt" src="https://github.com/user-attachments/assets/6b0b3074-13ff-402f-9c8f-a3f2f1e95df4" />
