{ ... }: {
  imports = [
    ./options.nix
    ./systems.nix
    ./nixos.nix
    ./packages.nix
    ./home.nix
  ];
}
