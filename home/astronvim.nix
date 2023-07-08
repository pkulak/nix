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

    "astronvim/lua/user/mappings.lua".text = ''
      return {
        n = {
          ["=j"] = { ":%!nix-shell -p jq --run jq<CR>:set syntax=json<CR>", desc = "Format JSON" },
          ["=x"] = { ":%!nix-shell -p libxml2 --run \"xmllint --format -\"<CR>:set syntax=xml<CR>", desc = "Format XML" },
          ["gb"] = { ":buffer #<cr>", desc = "Go to last buffer" },
          ["<leader>b"] = { name = "Buffers" },
          ["<leader>w"] = { ":wa<cr>", desc = "Save All" }
        }
      }
    '';
  };
}
