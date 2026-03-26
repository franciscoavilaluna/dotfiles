" =============================================================================
" PLUGIN: Autopairing Pro (Anidación, Borrado, Apóstrofos y Surround)
" =============================================================================

" --- 1. Borrado Sincronizado (Backspace) ---
function! s:SmartBS()
    let l:pairs = ['()', '[]', '{}', '""', "''", '``']
    let l:pair = getline('.')[col('.')-2 : col('.')-1]
    return (index(l:pairs, l:pair) != -1) ? "\<Right>\<BS>\<BS>" : "\<BS>"
endfunction

inoremap <expr> <BS> <SID>SmartBS()

" --- 2. Apertura e Inserción ---
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap ` ``<Left>

" Comillas inteligentes (No duplica en apóstrofos: don't, it's)
function! s:SmartQuotes(char)
    let l:prev = getline('.')[col('.') - 2]
    if l:prev =~# '\v\a|\d'
        return a:char
    endif
    return (getline('.')[col('.') - 1] == a:char) ? "\<Right>" : a:char . a:char . "\<Left>"
endfunction

inoremap <expr> ' <SID>SmartQuotes("'")
inoremap <expr> " <SID>SmartQuotes('"')

" --- 3. Cierre Inteligente (Salto) ---
inoremap <expr> ) getline('.')[col('.')-1] == ')' ? "\<Right>" : ")"
inoremap <expr> ] getline('.')[col('.')-1] == ']' ? "\<Right>" : "]"
inoremap <expr> } getline('.')[col('.')-1] == '}' ? "\<Right>" : "}"

" --- 4. Enter con Expansión de Bloque ---
inoremap <expr> <CR> getline('.')[col('.')-2:col('.')-1] == '{}' ? "\<CR>\<Esc>O" : "\<CR>"

" --- 5. Modo Visual: Envolver Selección (Surround) ---
" Selecciona texto y presiona (, [, {, ", o ' para envolverlo
vnoremap ( <Esc>`>a)<Esc>`<i(<Esc>
vnoremap [ <Esc>`>a]<Esc>`<i[<Esc>
vnoremap { <Esc>`>a}<Esc>`<i{<Esc>
vnoremap " <Esc>`>a"<Esc>`<i"<Esc>
vnoremap ' <Esc>`>a'<Esc>`<i'<Esc>
