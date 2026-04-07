{ self, inputs, ... }: {
  flake.nixosModules.linux-desktop = { pkgs, ... }: {
    imports = with self.nixosModules; [
      core
      desktop

      _1password
      fish
      game-devices
      jai
      niri
      nix-index
      rust
      smb
      snapper
    ];

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.pgen
      self.packages.${pkgs.stdenv.hostPlatform.system}.pixlet
    ];
  };

  flake.homeModules.linux-desktop = { ... }: {
    imports = with self.homeModules; [
      core
      desktop

      beets
      firefox
      fish
      ghostty
      git
      intellij
      jai
      jj
      mako
      matui
      mpd
      niri
      rofi
      secrets
      waybar
      yazi
    ];
  };
}
