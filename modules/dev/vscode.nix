# VSCode editor — Home Manager

{ config, pkgs, lib, ... }:
let
  user = config.user.name;
in
{
  home-manager.users.${user}.programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        zhuangtongfa.material-theme
        pkief.material-icon-theme
        jnoortheen.nix-ide
        ritwickdey.liveserver
        usernamehw.errorlens
        ziglang.vscode-zig
        ms-python.python
        ms-python.vscode-pylance
        ms-python.vscode-python-envs
        ms-python.debugpy
        danielgavin.ols
      ];

      userSettings = {
        "json.schemaDownload.trustedDomains"."https://raw.githubusercontent.com/" = true;
        "window.commandCenter" = false;
        "window.menuBarVisibility" = "toggle";
        "workbench.layoutControl.enabled" = false;
        "workbench.sideBar.location" = "right";
        "workbench.colorTheme" = "Stylix";
        "workbench.iconTheme" = "material-icon-theme";
        "breadcrumbs.enabled" = false;
        "editor.fontSize" = lib.mkDefault 16;
        "editor.formatOnSave" = true;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "terminal.external.linuxExec" = "kitty";
        "chat.disableAIFeatures" = true;
        "task.allowAutomaticTasks" = "on";
        "zig.zls.enabled" = "on";
        "ols.server.path" = "/run/current-system/sw/bin/ols";
      };
    };
  };
}
