{ self, inputs, ... }: {
  flake.nixosModules._1password = { ... }: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "phil" ];
    };
  };
}
