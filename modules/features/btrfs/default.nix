{ self, inputs, ... }:
{
  flake.nixosModules.btrfs =
    { ... }:
    {
      boot.kernelParams = [ "rd.luks.options=discard" ];

      fileSystems = {
        "/".options = [
          "compress-force=zstd"
          "autodefrag"
        ];
        "/home".options = [
          "compress-force=zstd"
          "autodefrag"
        ];
        "/nix".options = [
          "compress-force=zstd"
          "noatime"
          "nodiratime"
          "autodefrag"
        ];
        "/swap".options = [
          "noatime"
          "nodiratime"
        ];
      };
    };
}
