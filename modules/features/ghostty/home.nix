{ pkgs, ... }: {
  home.packages = [ pkgs.ghostty ];

  xdg.configFile."ghostty/config".text = ''
    theme = Catppuccin Mocha
    command = fish
    background = #181825
    background-opacity = 0.90
    font-size = 12
    window-padding-x = 2
    window-padding-y = 2
    window-padding-balance = true

    keybind = ctrl+c=copy_to_clipboard:plain
    keybind = ctrl+v=paste_from_clipboard

    keybind = ctrl+shift+c=text:\x03
    keybind = ctrl+shift+v=text:\x16
  '';

  systemd.user.services.ghostty = {
    Unit = {
      Description = "ghostty terminal server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" "dbus.socket" ];
      Requires = [ "dbus-socket" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify-reload";
      ReloadSignal = "SIGUSR2";
      BusName = "com.mitchellh.ghostty";
      ExecStart = "${pkgs.ghostty}/bin/ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false";
    };
    Install.WantedBy = [ "niri.service" ];
  };
}
