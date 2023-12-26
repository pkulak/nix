let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C";

  fry    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHT/UgnbVTNVHfcdGfnaFmRPwxTKtm8SZWVVV/3k/KDu";
  x1     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqzqd5PgJylsmJdYAZi0xRXD+nF8SQxuQVZVOZS7H45";
  t460p  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxLL9ihLEJdYgXX0qTtCBwexdC1ffA2Qh3wHPKhQHCM";

  keys = [ user fry x1 t460p ];
in {
  "jmap-secrets.age".publicKeys = keys;
  "smb-secrets.age".publicKeys = keys;
  "1pass.age".publicKeys = keys;
  "ha-secrets.age".publicKeys = keys;
}

# ssh-keyscan localhost
# add the new system key
# agenix --rekey
# commit
