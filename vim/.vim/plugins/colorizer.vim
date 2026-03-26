" 1. DEFINICIÓN DE LA FUNCIÓN
function! HighlightHexColors()
    " Limpia matches previos para no saturar memoria
    call clearmatches()

    let l:line_num = 1
    while l:line_num <= line('$')
        let l:line = getline(l:line_num)
        let l:col = match(l:line, '#\x\{6\}\>', 0)
        
        while l:col != -1
            let l:hex = matchstr(l:line, '#\x\{6\}\>', l:col)
            let l:group = 'hex_' . substitute(l:hex, '#', '', '')
            
            " Componentes RGB
            let l:r = str2nr(l:hex[1:2], 16)
            let l:g = str2nr(l:hex[3:4], 16)
            let l:b = str2nr(l:hex[5:6], 16)
            
            " Luminancia para contraste inteligente
            let l:luminance = (l:r * 0.299) + (l:g * 0.587) + (l:b * 0.114)
            let l:fg = l:luminance > 128 ? '#000000' : '#FFFFFF'
            
            exec 'hi ' . l:group . ' guifg=' . l:fg . ' guibg=' . l:hex
            call matchadd(l:group, l:hex, -1)
            
            let l:col = match(l:line, '#\x\{6\}\>', l:col + 1)
        endwhile
        let l:line_num += 1
    endwhile
endfunction

command! ColorMe call HighlightHexColors()
