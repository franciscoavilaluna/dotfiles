" menu: muestra el menú
" menuone: lo muestra aunque solo haya una opción
" noselect: no inserta el texto hasta que tú lo elijas
" noinsert: no cambia el texto que estás escribiendo mientras navegas
set completeopt=menu,menuone,noselect,noinsert
let g:auto_menu_enabled = 0

function! ShowCompletionMenu()
    " Si el menú ya está o no estamos en modo inserción real, salir
    if pumvisible() || mode() != 'i'
        return
    endif

    " Solo activar después de escribir un caracter de palabra (letra/número/_)
    " v:char es el caracter que acabas de presionar
    if v:char =~ '\k'
        " Usamos feedkeys para lanzar el comando de completado estándar
        " <C-n> busca palabras en los buffers abiertos
        call feedkeys("\<C-n>", "n")
    endif
endfunction

function! ToggleAutoMenu()
    if g:auto_menu_enabled == 0
        let g:auto_menu_enabled = 1
        augroup VanillaMenu
            autocmd!
            autocmd InsertCharPre * call ShowCompletionMenu()
        augroup END
        echo "Auto-Menu: ON"
    else
        let g:auto_menu_enabled = 0
        autocmd! VanillaMenu
        echo "Auto-Menu: OFF"
    endif
endfunction

nnoremap <leader>o :call ToggleAutoMenu()<CR>
