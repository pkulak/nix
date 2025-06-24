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
      "smb-secrets".file = ./smb-secrets.age;
    };
  };
}
