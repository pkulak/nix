{ self, ... }: {
  flake.nixosModules.apps = { pkgs, ... }: {
    imports = [
      self.nixosModules.packages
      self.nixosModules._1password
      self.nixosModules.fish
      self.nixosModules.rust
      self.nixosModules.jai
    ];
    environment.systemPackages = [
      self.packages.${pkgs.system}.pgen
      self.packages.${pkgs.system}.pixlet
    ];
  };

  flake.homeModules.apps = { ... }: {
    imports = [
      self.homeModules.beets
      self.homeModules.fish
      self.homeModules.ghostty
      self.homeModules.git
      self.homeModules.firefox
      self.homeModules.jai
      self.homeModules.matui
      self.homeModules.jj
      self.homeModules.secrets
      self.homeModules.yazi
    ];
  };
}
