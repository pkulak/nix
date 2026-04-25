{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ffmpeg-over-ip-client ];

  environment.etc."ffmpeg-over-ip.client.jsonc".source =
    pkgs.writeText "ffmpeg-over-ip.client.jsonc"
      (builtins.toJSON {
        address = "debian.home:5050";
        authSecret = "local-network-only";
        log = "stderr";
      });
}