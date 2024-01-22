{ config, pkgs, ... }:

{
  programs.waybar.settings.default.output = "HDMI-A-1";

  xdg.configFile."river/host" = {
    executable = true;

    # (1440 - (1080 / 1.25))
    # 1920 / 1.25
    text = ''
      wlr-randr --output eDP-1 --pos 0,576 --scale 1.25
      wlr-randr --output HDMI-A-1 --pos 1536,0
    '';
  };

  systemd.user.services.swayidle = {
    Unit.Description = "swayidle daemon";

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 300 '${pkgs.playerctl}/bin/playerctl pause' \
            timeout 600 'wlopm --off "*"' \
                    resume 'wlopm --on "*"' \

      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "river-session.target" ];
  };

  home.packages = [ pkgs.networkmanagerapplet ];

  systemd.user.services.nm-applet = {
    Unit.Description = "nm-applet daemon";
    Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    Install.WantedBy = [ "river-session.target" ];
  };
}
