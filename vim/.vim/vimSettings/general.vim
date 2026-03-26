" General settings

set nocompatible
let mapleader=" "

" UI settings
set number
set relativenumber
set ruler
set mouse=a
set showmatch
set showcmd
set wildmenu
set wildmode=longest:full,full
set linebreak
set breakindent
set history=1000
set laststatus=2
set noswapfile
set autoread
set mousehide
set path+=**
set backspace=indent,eol,start

" Syntax & highlighting
syntax enable
syntax on
highlight Comment cterm=italic
highlight Function cterm=italic
highlight Keyword cterm=italic
highlight Statement cterm=bold

" Clipboard
set clipboard=unnamed
set clipboard=unnamedplus
