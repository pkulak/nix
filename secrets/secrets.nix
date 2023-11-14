let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C";
  keys = [ user ];
in {
  "smb-secrets.age".publicKeys = keys;
  "1pass.age".publicKeys = keys;
}
