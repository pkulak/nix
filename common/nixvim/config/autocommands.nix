{
  autoCmd = [
    # Vertically center document when entering insert mode
    {
      event = "InsertEnter";
      command = "norm zz";
    }

    # Set indentation to 4 spaces for some things
    {
      event = "FileType";
      pattern = [ "rust" "java" "kotlin" ];
      command = "setlocal tabstop=4 shiftwidth=4";
    }

    # Enable spellcheck for some filetypes
    {
      event = "FileType";
      pattern = [ "tex" "latex" "markdown" ];
      command = "setlocal spell spelllang=en";
    }
  ];
}
