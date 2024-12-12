let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C";

  fry    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHT/UgnbVTNVHfcdGfnaFmRPwxTKtm8SZWVVV/3k/KDu";
  x1     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICspXgN3lyyzw0ElGhcqmeccdRBg5ZVXkalt3oM1Go+c";
  t460p  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxLL9ihLEJdYgXX0qTtCBwexdC1ffA2Qh3wHPKhQHCM";
  kvm    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1r9a/7YHv+zcAyn3V7t/a1X+hSRBYhGPJ93f3eQeBl";

  keys = [ user fry x1 t460p kvm ];
in {
  "smb-secrets.age".publicKeys = keys;
  "login.keyring.age".publicKeys = keys;
}

# ssh-keyscan localhost
# add the new system key
# agenix --rekey
# commit

# add a line for the new secret file
# agenix -e new-secret.age
# save the file
