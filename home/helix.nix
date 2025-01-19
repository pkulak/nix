{  pkgs, ... }:

{
  home.packages = with pkgs; [
      jq
      helix
      nixpkgs-fmt
      nil
      rust-analyzer
      libxml2
      marksman
      unstable.harper
  ];

  xdg.configFile = {
    "helix/config.toml".text = ''
      theme = "catppuccin_mocha"

      [editor]
      auto-pairs = false

      [editor.cursor-shape]
      insert = "bar"
      normal = "block"
      select = "underline"

      [keys.normal]
      X = "extend_line_below"
      x = "extend_to_line_bounds"

      [keys.insert.j]
      x = [":wa", ":q!"]

      [keys.normal."="]
      s = ["select_all", ":pipe sort"]
      j = ["select_all", ":pipe jq", ":lang json"]
      x = ["select_all", ":pipe xmllint --format -", ":lang xml"]
    '';

    "helix/languages.toml".text = ''
      [language-server.rust-analyzer.config.check]
      command = "clippy"

      [language-server.harper-ls]
      command = "harper-ls"
      args = ["--stdio"]

      [[language]]
      name = "nix"
      formatter = { command = "nixpkgs-fmt" }

      [[language]]
      name = "markdown"
      language-servers = [ "harper-ls" ]
    '';
  };
}
