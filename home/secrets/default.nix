{ config, ... }:

let
  mkSecret = file: name: {
    file = file;
    path = "/run/user/1000/agenix/${name}";
  };
in {
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets = {
      aws-credentials = mkSecret ./aws-credentials.age "aws-credentials";
      login-keyring = mkSecret ./login.keyring.age "login-keyring";
      m2-settings = mkSecret ./m2-settings.xml.age "m2-settings";
      smb-secrets = mkSecret ./smb-secrets.age "smb-secrets";
    };
  };

  home.file = with config.age.secrets; with config.lib.file; {
    ".local/share/keyrings/login.keyring".source = mkOutOfStoreSymlink login-keyring.path;
    ".aws/credentials".source = mkOutOfStoreSymlink aws-credentials.path;
    ".m2/settings.xml".source = mkOutOfStoreSymlink m2-settings.path;
  };
}
