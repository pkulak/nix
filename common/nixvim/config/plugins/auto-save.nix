{
  plugins.auto-save = {
    enable = true;

    condition = ''
      function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        if
          fn.getbufvar(buf, "&modifiable") == 1
          and not utils.set_of({'md', 'markdown'})[fn.getbufvar(buf, "&filetype")]
        then
          return true -- met condition(s), can save
        end
        return false -- can't save
      end
    '';
  };
}
