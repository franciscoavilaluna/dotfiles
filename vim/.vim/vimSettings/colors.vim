if $VIM_EINK == "1"
    set bg=light
    colorscheme quiet
    set t_Co=0
    highlight Normal ctermbg=White ctermfg=Black
    highlight Statusline ctermbg=Black ctermfg=white
else
    syntax on 
    set termguicolors
    set laststatus=1
    set bg=dark
    let base16colorspace=256
    autocmd VimEnter * highlight Normal ctermbg=NONE guibg=NONE
    colorscheme catppuccin
endif
