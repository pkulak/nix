{ config, pkgs, ... }:

{
  wayland.windowManager.sway.config = {
    input = {
      "1:1:AT_Translated_Set_2_keyboard" = {
        xkb_options = "altwin:swap_lalt_lwin,caps:escape";
      };

      "1739:0:Synaptics_TM3289-021" = {
        scroll_factor = "0.5";
      };
    };

    keybindings = pkgs.lib.mkOptionDefault {
      "--locked Print" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
      "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
    };
  };

  wayland.windowManager.sway.extraConfig = "workspace 1";

  systemd.user.services.swayidle = {
    Unit.Description = "swayidle daemon";

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 120 'wlopm --off "*"' \
                    resume 'wlopm --on "*"' \
            timeout 600 'systemctl suspend' \
                    after-resume 'wlopm --on "*"'

      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "sway-session.target" ];
  };

  home.packages = [ pkgs.networkmanagerapplet ];

  systemd.user.services.nm-applet = {
    Unit.Description = "nm-applet daemon";
    Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    Install.WantedBy = [ "sway-session.target" ];
  };
}
