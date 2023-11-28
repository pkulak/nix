{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.jq
    pkgs.libxml2
  ];

  xdg.configFile = {
    nvim = {
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev = "v3.36.6";
        sha256 = "sha256-XbvqX7xEdgfS8/fNvkwB4x7SW4S/Myh3MJS8TH70Xs0=";
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
