{ config, pkgs, ... }:

{
  programs.fish.shellAliases = {
    ts = "sudo tailscale switch kulak.us && sudo tailscale up";
  };

  systemd.user.services.swayidle = {
    Unit = {
      Description = "swayidle daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 600 'wlopm --off "*"' \
                    resume 'wlopm --on "*"' \
            timeout 7200 'systemctl suspend' \
                    after-resume 'wlopm --on "*"'
      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "niri.service" ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
