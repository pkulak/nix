{ self, ... }:
{
  perSystem = { pkgs, ... }:
    let
      ffmpeg-over-ip-client = pkgs.callPackage ./package.nix {};
    in
    {
      packages.ffmpeg-over-ip-client = ffmpeg-over-ip-client;
      packages.ffmpeg-over-ip = pkgs.runCommandLocal "ffmpeg-over-ip" {} ''
        mkdir -p $out/bin
        ln -s ${ffmpeg-over-ip-client}/bin/ffmpeg-over-ip-client $out/bin/ffmpeg
        ln -s ${ffmpeg-over-ip-client}/bin/ffmpeg-over-ip-ffprobe $out/bin/ffprobe
      '';
    };

  flake.nixosModules.ffmpeg-over-ip = import ./nixos.nix;
}