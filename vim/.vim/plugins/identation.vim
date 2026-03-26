" 1. Activar el modo de lista (muestra caracteres invisibles)
set list

" 2. Definir los caracteres: 
" Usamos una barra vertical para el inicio de los tabs
" Y un punto sutil para los espacios si quieres verlos todos
set listchars=tab:\|\ ,trail:·,leadmultispace:\|\ \ \ 

" 3. DARLES COLOR (Esto es lo que suele faltar)
" Si no definimos el color, Vim usa el mismo que el texto y no se nota
highlight NonText ctermfg=239 guifg=#C7C7C7
highlight SpecialKey ctermfg=239 guifg=#C7C7C7
highlight Whitespace ctermfg=239 guifg=#C7C7C7
