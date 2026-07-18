{ pkgs, lib, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # style
        zhuangtongfa.material-theme
        pkief.material-icon-theme

        # nix
        jnoortheen.nix-ide

        # web
        ritwickdey.liveserver

        # debugging
        usernamehw.errorlens

        # vscode
        ziglang.vscode-zig

        # python
        ms-python.python
        ms-python.vscode-pylance
        ms-python.vscode-python-envs
        ms-python.debugpy
      ];

      userSettings = {
        # window / ui
        "window.commandCenter" = false;
        "window.menuBarVisibility" = "toggle";
        "workbench.layoutControl.enabled" = false;
        "workbench.sideBar.location" = "right";

        # theme
        "workbench.colorTheme" = "Stylix";
        "workbench.iconTheme" = "material-icon-theme";

        # editor
        "breadcrumbs.enabled" = false;
        "editor.fontSize" = lib.mkDefault 16;
        "editor.formatOnSave" = true;

        # xplorer
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;

        # terminal
        "terminal.external.linuxExec" = "kitty";

        # AI features
        "chat.disableAIFeatures" = true;

        # tasks
        "task.allowAutomaticTasks" = "on";
      };
    };
  };
}
