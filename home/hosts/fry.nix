{ config, pkgs, ... }:

{
  systemd.user.services.swayidle = {
    Unit.Description = "swayidle daemon";

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 600 'swaymsg "output * dpms off"' \
                    resume 'swaymsg "output * dpms on"'
      ''; 

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "sway-session.target" ];
  };

  systemd.user.services.buzz = {
    Unit.Description = "buzz daemon";
    Service.ExecStart = "${pkgs.callPackage ../../common/buzz pkgs}/bin/buzz"; 
    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "sway-session.target" ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
