{ agenix, system, ... }:

let
  mkSecret = file: {
    inherit file;
    owner = "phil";
    group = "users";
    mode = "600";
  };
in
{
  environment.systemPackages = [
    agenix.packages.${system}.default
  ];

  age = {
    secrets = {
      "aws-credentials" = mkSecret ./aws-credentials.age;
      "login.keyring" = mkSecret ./login.keyring.age;
      "m2-settings.xml" = mkSecret ./m2-settings.xml.age;
      "smb-secrets".file = ./smb-secrets.age;
    };
  };
}
