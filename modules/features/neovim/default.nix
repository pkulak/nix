{ inputs, ... }:
let
  module = import ./module.nix;
  wrapper = inputs.wrappers.lib.evalModule module;
in
{
  perSystem = { system, ... }: {
    packages.neovim =
      let
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in
      wrapper.config.wrap { inherit pkgs; };
  };
}
