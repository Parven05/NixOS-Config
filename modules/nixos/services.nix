{ ... }: {
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  services.flatpak.enable = true;

  systemd.services.pi-bot = {
    description = "Pi Bot - Discord bot powered by DeepSeek";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/home/parven/Dev/Pi-Bot";
      ExecStart = "/home/parven/Dev/Pi-Bot/.venv/bin/python bot.py";
      User = "parven";
      Restart = "on-failure";
      RestartSec = 5;
      EnvironmentFile = "/home/parven/Dev/Pi-Bot/.env";
    };
  };
}
