{ self, inputs, ... }:
{
  flake.nixosModules.linux-server =
    { ... }:
    {
      networking.tempAddresses = "disabled";

      imports = with self.nixosModules; [
        core

        fish
        nix-index
        smb
      ];
    };

  flake.homeModules.linux-server =
    { ... }:
    {
      imports = with self.homeModules; [
        core

        beets
        env
        fish
        git
        jj
        pi
        secrets
        yazi
      ];
    };
}
