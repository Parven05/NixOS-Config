{ pkgs, lib, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        stylix.stylix
        jnoortheen.nix-ide
        pkief.material-icon-theme
        ritwickdey.liveserver
        usernamehw.errorlens
        zhuangtongfa.material-theme
        ziglang.vscode-zig
        ms-python.python
        ms-python.vscode-pylance
        ms-python.vscode-python-envs
        ms-python.debugpy
      ];

      userSettings = {
        "window.menuBarVisibility" = "toggle";
        "workbench.colorTheme" = "Stylix";
        "window.commandCenter" = false;
        "chat.disableAIFeatures" = true;
        "editor.fontSize" = lib.mkDefault 16;
        "workbench.iconTheme" = "material-icon-theme";
        "terminal.external.linuxExec" = "kitty";
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "editor.formatOnSave" = true;
        "task.allowAutomaticTasks" = "on";
        "workbench.layoutControl.enabled" = false;
        "breadcrumbs.enabled" = false;
        "workbench.sideBar.location" = "right";
      };
    };
  };
}
