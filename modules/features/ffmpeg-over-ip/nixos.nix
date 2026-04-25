{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ffmpeg-over-ip-client ];
}