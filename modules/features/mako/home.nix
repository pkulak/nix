{ pkgs, ... }: {
  home.packages = [ pkgs.mako ];

  xdg.configFile."mako/config".text = ''
    font=monospace 12

    background-color=#181825
    text-color=#cdd6f4
    border-color=#94e2d5
    progress-color=over #313244
    border-radius=6

    [urgency=high]
    border-color=#fab387
  '';

  systemd.user.services.mako = {
    Unit = {
      Description = "mako daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.mako}/bin/mako";
    Install.WantedBy = [ "niri.service" ];
  };
}
