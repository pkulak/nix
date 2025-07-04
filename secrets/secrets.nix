let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C";

  fry    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHT/UgnbVTNVHfcdGfnaFmRPwxTKtm8SZWVVV/3k/KDu";
  x1     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICspXgN3lyyzw0ElGhcqmeccdRBg5ZVXkalt3oM1Go+c";
  kvm    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1r9a/7YHv+zcAyn3V7t/a1X+hSRBYhGPJ93f3eQeBl";

  keys = [ user fry x1 kvm ];
in {
  "smb-secrets.age".publicKeys = keys;
  "login.keyring.age".publicKeys = keys;
  "aws-credentials.age".publicKeys = keys;
  "m2-settings.xml.age".publicKeys = keys;
}

# ssh-keyscan localhost
# add the new system key
# agenix --rekey
# commit

# add a line for the new secret file
# agenix -e new-secret.age
# save the file
