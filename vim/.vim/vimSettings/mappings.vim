" Reload config and colorscheme selector
nmap <leader>rl :source ~/.vimrc<CR>
map <leader>cs :colorscheme <C-D>

" Splits
nnoremap <C-w>- :split<CR>
nnoremap <C-w>\ :vsplit<CR>

" Buffer navigation
nnoremap <C-left> :bprevious<CR>
nnoremap <C-right> :bnext<CR>

" Rezise windows
nnoremap <C-w><up> :resize +3<CR>
nnoremap <C-w><down> :resize -3<CR>
nnoremap <C-w><left> :vertical resize -3<CR>
nnoremap <C-w><right> :vertical resize +3<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Cursor positioning
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Line manipulation
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
nnoremap J mzJ`z

" Miscellaneous mappings
"inoremap <C-c> <Esc>
nnoremap Q <nop>
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
nnoremap <leader>x :!chmod +x %<CR>

" File searching
nnoremap <Leader>pf :find<Space>

" Move window
nnoremap <C-w>H <C-w>H
nnoremap <C-w>J <C-w>J
nnoremap <C-w>K <C-w>K
nnoremap <C-w>L <C-w>L

" Omnicompletion
"inoremap <C-n> <C-x><C-n>
"inoremap <C-l> <C-x><C-l>
"inoremap <C-o> <C-x><C-o>
"inoremap <C-f> <C-x><C-f>
"inoremap <C-d> <C-x><C-d>
"inoremap <C-s> <C-x><C-s>
"inoremap <C-]> <C-x><C-]>
"inoremap <C-k> <C-x><C-k>
"inoremap <C-t> <C-x><C-t>
