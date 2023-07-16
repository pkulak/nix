{ config, pkgs, ... }:

{
  wayland.windowManager.sway.config = {
    startup = [ {
      command = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 600 'swaymsg "output * dpms off"' \
                    resume 'swaymsg "output * dpms on"' \
            timeout 10800 'systemctl suspend' \
                    after-resume 'swaymsg "output * dpms on"'
      '';
    } {
      command = "${pkgs.callPackage ../../common/buzz pkgs}/bin/buzz";
    } ];
  };
}
