{
  plugins.lsp = {
    enable = true;

    keymaps = {
      silent = true;

      diagnostic = {
        "<leader>k" = {
          action = "goto_prev";
          desc = "Previous Diagnostic";
        };

        "<leader>j" = {
          action = "goto_next";
          desc = "Next Diagnostic";
        };
      };

      lspBuf = {
        "gd" = {
          action = "definition";
          desc = "Goto Definition";
        };
        "gD" = {
          action = "references";
          desc = "Goto References";
        };
        "gt" = {
          action = "type_definition";
          desc = "Goto Type Definition";
        };
        "gi" = {
          action = "implementation";
          desc = "Goto Implementation";
        };
        "K" = {
          action = "hover";
          desc = "Hover";
        };
        "<leader>lr" = {
          action = "rename";
          desc = "Rename";
        };
        "<leader>la" = {
          action = "code_action";
          desc = "Code Action";
        };
      };
    };

    servers = {
      java-language-server.enable = true;
      kotlin-language-server.enable = true;
      nil_ls.enable = true;

      rust-analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
    };
  };

  plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
  };

  plugins.lsp-format = {
    enable = true;
    lspServersToEnable = [ "rust-analyzer" ];
  };

  plugins.luasnip.enable = true;

  plugins.cmp = {
    enable = true;
    autoEnableSources = true;

    settings = {
      snippet.expand =
        "function(args) require('luasnip').lsp_expand(args.body) end";

      sources =
        [ { name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } ];

      mapping = {
        __raw = ''
          cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
               local luasnip = require('luasnip')

               if cmp.visible() then
                 cmp.select_next_item()
               elseif luasnip.expand_or_jumpable() then
                 luasnip.expand_or_jump()
               else
                 fallback()
               end
             end, { 'i', 's' }),
             ['<S-Tab>'] = cmp.mapping(function(fallback)
               local luasnip = require('luasnip')

               if cmp.visible() then
                 cmp.select_prev_item()
               elseif luasnip.jumpable(-1) then
                 luasnip.jump(-1)
               else
                 fallback()
               end
             end, { 'i', 's' }),
          })
        '';
      };
    };
  };

  keymaps = [{
    key = "<leader>lf";
    options.silent = true;
    action = ":Format<CR>";
    options.desc = "Format";
  }];
}
