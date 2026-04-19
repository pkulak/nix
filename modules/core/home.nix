{ self, inputs, ... }: {
  flake.homeModules.core = { config, pkgs, host, ... }:
    let
      rebuild = pkgs.writeShellApplication {
        name = "rebuild";
        text = "sudo nixos-rebuild --flake ~/nix/#${host} switch";
      };

      update = pkgs.writeShellApplication {
        name = "update";
        text = ''
          cd ~/nix
          nix flake update --flake ~/nix
          cd "$OLDPWD"
        '';
      };

      public-key =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C phil@kulak.us";
    in {
      home = {
        username = "phil";
        homeDirectory = "/home/phil";
        packages = [ rebuild update ];
      };

      home.file = {
        # SSH
        ".ssh/allowed_signers".text = "* ${public-key}";
        ".ssh/id_ed25519.pub".text = public-key;
      };
    };
}
