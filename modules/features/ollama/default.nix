{ self, inputs, ... }: { flake.nixosModules.ollama = import ./nixos.nix; }
