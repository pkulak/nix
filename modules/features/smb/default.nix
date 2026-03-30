{ self, inputs, ... }: { flake.nixosModules.smb = import ./nixos.nix; }
