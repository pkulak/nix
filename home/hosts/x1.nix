{ pkgs, lib, ... }:

{
  programs.fish.shellAliases = {
    ts = "sudo tailscale switch kulak.us && sudo tailscale up --accept-routes";
  };

  xdg.configFile."niri/environment" = {
    text = "export XKB_DEFAULT_OPTIONS=altwin:swap_lalt_lwin,caps:escape";
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
            timeout 120 'wlopm --off "*"' \
                    resume 'wlopm --on "*"' \
            timeout 600 'systemctl suspend' \
                    after-resume 'wlopm --on "*"'

      '';

    Service.Environment = "PATH=/bin:/run/current-system/sw/bin";
    Install.WantedBy = [ "niri.service" ];
  };

  programs.firefox.profiles.phil.extraConfig = ''
    user_pref("mousewheel.default.delta_multiplier_y", 50);
  '';

  home.packages = [ pkgs.networkmanagerapplet ];

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "network manager applet";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    Install.WantedBy = [ "niri.service" ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
