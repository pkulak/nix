{ pkgs, ... }:

let 
  jai = (pkgs.callPackage ./jai.nix {});
in {
  security.wrappers.jai = {
    source = "${jai}/bin/jai";
    owner = "root";
    group = "root";
    setuid = true;
  };
}
