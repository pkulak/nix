{ config, pkgs, ... }:

# After an update, you may need to run this:
#
# mv ~/.local/share/nvim ~/.local/share/nvim.bak
# mv ~/.local/state/nvim ~/.local/state/nvim.bak
# mv ~/.cache/nvim ~/.cache/nvim.bak

{
  home.packages = with pkgs; [
    bacon
    cargo
    clippy
    jq
    libxml2
    rustfmt
    rustc
    rust-analyzer
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
          ["=s"] = { ":%sort<CR>", desc = "Sort lines" },
          ["gb"] = { ":buffer #<cr>", desc = "Go to last buffer" },
          ["<leader>b"] = { name = "Buffers" },
          ["<leader>w"] = { ":wa<cr>", desc = "Save All" }
        }
      }
    '';
  };
}
