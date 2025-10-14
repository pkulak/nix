{  pkgs, ... }:

{
  # Enables the 1Password CLI
  programs._1password = { enable = true; };

  # Enables the 1Password desktop app
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "phil" ];
  };
}
