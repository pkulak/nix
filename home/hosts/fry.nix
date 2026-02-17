{ config, pkgs, ... }:

{
  programs.fish.shellAliases = {
    ts = "sudo tailscale switch kulak.us && sudo tailscale up";
  };

  xdg.configFile."niri/host.kdl".text = # kdl
    ''
      window-rule {
          match app-id="com.mitchellh.ghostty"
          default-column-width { proportion 0.3; }
      }

      window-rule {
          match app-id="jetbrains-idea"
          default-column-width { proportion 0.6; }
      }

      window-rule {
          match app-id="com.mitchellh.ghostty" title="Matui"
          default-column-width { proportion 0.4; }
      }

      window-rule {
          match app-id="com.mitchellh.ghostty" title="termfilechooser"
          default-column-width { proportion 0.5; }
      }

      window-rule {
          match app-id=r#"firefox$"#
          default-column-width { proportion 0.5; }
      }
    '';

  systemd.user.services.swayidle = {
    Unit = {
      Description = "swayidle daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };

    Service.ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
            timeout 300 'playerctl pause' \
            timeout 600 'niri msg action power-off-monitors' \
            timeout 7200 'systemctl suspend'
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
