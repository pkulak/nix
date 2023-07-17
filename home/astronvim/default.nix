{ config, pkgs, ... }:

{
  xdg.configFile = {
    nvim = {
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev = "v3.31.2";
        sha256 = "sha256-6UMIb7d+UADbf6p5FJU2AArNDk7Ur9Lzb+WykQkNB/I=";
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
          ["=j"] = { ":%!${pkgs.jq}/bin/jq<CR>:set syntax=json<CR>", desc = "Format JSON" },
          ["=x"] = { ":%!${pkgs.libxml2}/bin/xmllint --format -<CR>:set syntax=xml<CR>", desc = "Format XML" },
          ["gb"] = { ":buffer #<cr>", desc = "Go to last buffer" },
          ["<leader>b"] = { name = "Buffers" },
          ["<leader>w"] = { ":wa<cr>", desc = "Save All" }
        }
      }
    '';
  };
}
