let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C";

  fry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHT/UgnbVTNVHfcdGfnaFmRPwxTKtm8SZWVVV/3k/KDu";

  keys = [ user fry ];
in {
  "smb-secrets.age".publicKeys = keys;
  "1pass.age".publicKeys = keys;
}

# ssh-keyscan localhost
# add the new system key
# agenix --rekey
# commit
