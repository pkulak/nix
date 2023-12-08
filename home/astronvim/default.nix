{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.jq
    pkgs.libxml2
    pkgs.rust-analyzer
  ];

  xdg.configFile = {
    nvim = {
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev = "v3.39.0";
        sha256 = "sha256-wttBcj9OoFHx+EukGzQYKHVlApphZXzZqY5zP5chU6g=";
      };
    };

    # Include some stuff as plain source
    "astronvim/lua/user/init.lua".source = ./user/init.lua;
    "astronvim/lua/user/options.lua".source = ./user/options.lua;
    "astronvim/lua/user/plugins".source = ./user/plugins;

    # But do the mappings here so we can have substitutions
    "astronvim/lua/user/mappings.lua".text = ''
      return {
        n = {
          ["=j"] = { ":%!jq<CR>:set syntax=json<CR>", desc = "Format JSON" },
          ["=x"] = { ":%!xmllint --format -<CR>:set syntax=xml<CR>", desc = "Format XML" },
          ["gb"] = { ":buffer #<cr>", desc = "Go to last buffer" },
          ["<leader>b"] = { name = "Buffers" },
          ["<leader>w"] = { ":wa<cr>", desc = "Save All" }
        }
      }
    '';
  };
}
