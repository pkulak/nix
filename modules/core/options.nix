{ inputs, lib, ... }: {
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      homeModules = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = {};
      };
    };
  };
}
