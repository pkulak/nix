{ self, ... }: {
  flake.nixosModules.desktop = { ... }: {
    imports = [
      self.nixosModules.niri
    ];
  };

  flake.homeModules.desktop = { ... }: {
    imports = [
      self.homeModules.ghostty
      self.homeModules.mako
      self.homeModules.mpd
      self.homeModules.niri
      self.homeModules.rofi
      self.homeModules.waybar
    ];
  };
}
