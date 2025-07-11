{ config, ... }:

{
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets = {
      aws-credentials.file = ./aws-credentials.age;
      login-keyring.file = ./login.keyring.age;
      m2-settings.file = ./m2-settings.xml.age;
      smb-secrets.file = ./smb-secrets.age;
    };
  };

  home.file = with config.age.secrets; with config.lib.file; {
    ".local/share/keyrings/login.keyring".source = mkOutOfStoreSymlink login-keyring.path;
    ".aws/credentials".source = mkOutOfStoreSymlink aws-credentials.path;
    ".m2/settings.xml".source = mkOutOfStoreSymlink m2-settings.path;
  };
}
