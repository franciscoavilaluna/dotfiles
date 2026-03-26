 " python
autocmd FileType python nnoremap <C-x> :w<CR>:!clear && python3 %<CR>

" c
autocmd FileType c nnoremap <C-x> :w<CR>:!clear && gcc % -o %< && ./%<<CR>

" cpp
autocmd FileType cpp nnoremap <C-x> :w<CR>:!clear && g++ % -o %< && ./%<<CR>

" sh autocmd FileType sh nnoremap <C-x> :w<CR>:!clear && bash %<CR> " php
autocmd FileType php nnoremap <C-x> :w<CR>:silent !pgrep -x php > /dev/null \|\| php -S localhost:8000 > /dev/null 2>&1 & sleep 0.5 && xdg-open http://localhost:8000/%:t<CR>:redraw!<CR>

" html
autocmd FileType html nnoremap <C-x> :w<CR>:silent !pgrep -x php > /dev/null \|\| php -S localhost:8000 > /dev/null 2>&1 & sleep 0.2 && xdg-open http://localhost:8000/%:t<CR>:redraw!<CR>

" close all
autocmd VimLeave *.php,*.html silent !killall php > /dev/null 2>&1

" convert md to pdf with pandoc
nnoremap <C-x> :w<CR>:silent !pandoc % -o %:r.pdf --pdf-engine=pdflatex &<CR>:redraw!<CR>:echo "Generating PDF..."<CR>
