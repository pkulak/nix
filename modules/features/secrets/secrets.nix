let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWOTXI/ryuoyQSepiKc+EF5lm+Ye3vqa2a5xS4pBA4C";
  keys = [ user ];
in {
  "smb-secrets.age".publicKeys = keys;
  "aws-credentials.age".publicKeys = keys;
  "m2-settings.xml.age".publicKeys = keys;
  "env.age".publicKeys = keys;
}

# add a line for the new secret file
# agenix -e new-secret.age
# save the file
