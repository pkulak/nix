{ self, inputs, ... }: {
  flake.nixosModules.linux-server = { ... }: {
    imports = with self.nixosModules; [
      core

      fish
      nix-index
      smb
    ];
  };

  flake.homeModules.linux-server = { ... }: {
    imports = with self.homeModules; [
      core

      beets
      fish
      git
      jj
      secrets
      yazi
    ];
  };
}
