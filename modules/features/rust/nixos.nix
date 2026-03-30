{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bacon
    cargo
    clippy
    rustfmt
    rustc
  ];
}
