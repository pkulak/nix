{ inputs, ... }:
{
  flake.homeModules.hunk.imports = [
    inputs.hunk.homeManagerModules.default
    ./home.nix
  ];
}
