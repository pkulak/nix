{ config, pkgs, ... }:

{
  xdg.configFile."river/host" = {
    executable = true;
    text = ''
      for mode in normal locked
      do
        riverctl map $mode None Print spawn playerctl play-pause
      done
    '';
  };

  xdg.configFile."river/environment" = {
    text = "export XKB_DEFAULT_OPTIONS=altwin:swap_lalt_lwin,caps:escape";
  };

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
    Install.WantedBy = [ "river-session.target" ];
  };

  programs.firefox.profiles.phil.extraConfig = ''
    user_pref("mousewheel.default.delta_multiplier_y", 50);
  '';

  home.packages = [ pkgs.networkmanagerapplet ];

  systemd.user.services.nm-applet = {
    Unit.Description = "nm-applet daemon";
    Service.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    Install.WantedBy = [ "river-session.target" ];
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
