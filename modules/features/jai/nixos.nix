{ pkgs, ... }:

let 
  jai = (pkgs.callPackage ./nixos/jai.nix {});
in {
  security.wrappers.jai = {
    source = "${jai}/bin/jai";
    owner = "root";
    group = "root";
    setuid = true;
  };

  users.users.jai = {
    isSystemUser = true;
    group = "jai";
    description = "JAI sandbox untrusted user";
    home = "/";
  };

  users.groups.jai = {};
}
