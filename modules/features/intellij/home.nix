{ pkgs, ... }: {
  home.packages = [ pkgs.jetbrains.idea ];
  
  home.file.".ideavimrc".text = ''
    set ignorecase
    set smartcase
    set relativenumber
    set number
    inoremap jj <esc>
    set visualbell
  '';
}
