{ ... }:
{
  flake.homeModules.pi = import ./home.nix;

  perSystem =
    { pkgs, ... }:
    {
      packages.pi-agent-browser-native = pkgs.callPackage ./pi-agent-browser-native.nix { };
    };
}
