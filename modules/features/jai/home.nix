{ config, ... }:

let
  agentPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgVKFb5W+aqkySq65AdTNklx6fgsflItBk3EYJZXll0 phil@fry";
  agentAllowedSigners = "* ${agentPublicKey}";
in
{
  home.file = {
    ".jai/default.conf".source = ./home/default.conf;
    ".jai/default.jail".source = ./home/default.jail;
    ".jai/pi.jail".source = ./home/pi.jail;
    "agents/AGENTS.md".source = ./home/AGENTS.md;

    ".jai/pi.home/.ssh/config".text = ''
      Host *
        BatchMode yes
        StrictHostKeyChecking accept-new
    '';
    ".jai/pi.home/.ssh/id_ed25519".source =
      config.lib.file.mkOutOfStoreSymlink config.age.secrets.agent-key.path;
    ".jai/pi.home/.ssh/id_ed25519.pub".text = agentPublicKey;
    ".jai/pi.home/.ssh/allowed_signers".text = agentAllowedSigners;
  };
}
