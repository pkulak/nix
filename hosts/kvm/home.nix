{ ... }: {
  home.stateVersion = "23.05";
  xdg.configFile."niri/host.kdl".text = # kdl
    ''
      // VM: no hardware output or input overrides needed
    '';
}
