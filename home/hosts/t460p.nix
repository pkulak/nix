{ config, pkgs, ... }:

{
  programs.waybar.settings.default.output = "HDMI-A-1";

  wayland.windowManager.sway.config = {
    # (1440 - (1080 / 1.25))
    # 1920 / 1.25
    output = {
      "eDP-1" = { pos = "0 576 scale 1.25"; };
      "HDMI-A-1" = { pos = "1536 0"; };
    };

    keybindings = pkgs.lib.mkOptionDefault {
      "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
      "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
    };
  };

  wayland.windowManager.sway.extraConfig = "workspace 1";

  systemd.user.services.swayidle = {
    Unit.Description = "swayidle daemon";

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 300 '${pkgs.playerctl}/bin/playerctl pause' \
            timeout 600 'swaymsg "output * dpms off"' \
                    resume 'swaymsg "output * dpms on"' \
      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "sway-session.target" ];
  };

  systemd.user.services.nm-applet = {
    Unit.Description = "nm-applet daemon";
    Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    Install.WantedBy = [ "sway-session.target" ];
  };
}
