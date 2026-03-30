{ ... }: {
  xdg.configFile."niri/host.kdl".text = # kdl
    ''
      // VM: no hardware output or input overrides needed
    '';
}
