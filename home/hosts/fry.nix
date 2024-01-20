{ config, pkgs, ... }:

{
  systemd.user.services.swayidle = {
    Unit.Description = "swayidle daemon";

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 600 'hyprctl dispatch dpms off' \
                    resume 'hyprctl dispatch dpms on && systemctl --user restart wlsunset' \
            timeout 7200 'systemctl suspend' \
                    after-resume 'hyprctl dispatch dpms on && systemctl --user restart wlsunset'
      ''; 

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
