{ self, inputs, ... }: { flake.nixosModules.snapper = import ./nixos.nix; }
