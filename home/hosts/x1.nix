{ config, pkgs, ... }:

{
  wayland.windowManager.sway.config = {
    startup = [ {
      command = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 120 'swaymsg "output * dpms off"' \
                    resume 'swaymsg "output * dpms on"' \
            timeout 600 'systemctl suspend' \
                    after-resume 'swaymsg "output * dpms on"'
      '';
    } {
      command = "nm-applet";
    }];

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
}
