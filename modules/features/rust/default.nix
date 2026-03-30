{ self, inputs, ... }: { flake.nixosModules.rust = import ./nixos.nix; }
