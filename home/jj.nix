_:

{
  xdg.configFile = {
    "jj/config.toml".text = ''
      [user]
        name = "Phil Kulak"
        email = "phil.kulak@vevo.com"

      [ui]
        paginate = "never"
        default-command = "log"

      [signing]
        sign-all = true
        backend = "ssh"
        key = "/home/phil/.ssh/id_ed25519.pub"

      [revsets]
        log = "latest(all(), 15)"
    '';
  };
}
