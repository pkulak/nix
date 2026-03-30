{ self, inputs, ... }: { flake.nixosModules.vm = import ./nixos.nix; }
