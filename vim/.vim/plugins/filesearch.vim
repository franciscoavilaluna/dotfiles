function! s:UpdatePreview()
    let l:file = getline('.')
    let l:preview_buf = bufwinnr('__Preview__')
    
    " Solo actualizar si el archivo existe y es legible
    if l:preview_buf != -1 && filereadable(l:file)
        let l:content = systemlist("head -n 25 " . shellescape(l:file))
        
        execute l:preview_buf . "wincmd w"
        setlocal modifiable
        silent %delete _
        call setline(1, l:content)
        " Intentar detectar el lenguaje para que el preview tenga colores
        filetype detect
        setlocal nomodifiable
        wincmd p
    endif
endfunction

function! s:CleanAndOpen()
    let l:file = getline('.')
    " 1. Cerrar la ventana de preview si existe
    let l:p_win = bufwinnr('__Preview__')
    if l:p_win != -1 | execute l:p_win . 'bwipeout!' | endif
    
    " 2. Cerrar la ventana del buscador actual
    bwipeout!
    
    " 3. Abrir el archivo seleccionado
    if filereadable(l:file)
        execute 'edit ' . l:file
    endif
endfunction

function! s:FindFile()
    let l:query = input("Buscar archivo: ")
    if empty(l:query) | return | endif
    let l:files = systemlist("find . -maxdepth 3 -not -path '*/.*' -name '*" . l:query . "*'")
    
    if empty(l:files)
        redraw | echo " No se encontraron archivos."
        return
    endif

    " Crear Preview a la derecha
    execute "botright vnew __Preview__"
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
    wincmd p

    " Crear Buscador abajo
    execute "botright 10new __Buscador__"
    setlocal buftype=nofile bufhidden=wipe noswapfile
    call setline(1, l:files)
    
    " Al mover el cursor, actualizar preview
    autocmd CursorMoved <buffer> call s:UpdatePreview()

    " MAPEOS REVISADOS
    " Al presionar Enter, llama a la función de limpieza y apertura
    nnoremap <buffer> <CR> :call <SID>CleanAndOpen()<CR>
    
    " Al presionar 'q', cierra el buscador y el preview
    nnoremap <buffer> q :let p=bufwinnr('__Preview__') <bar> if p!=-1 <bar> exe p.'bw!' <bar> endif <bar> bw!<CR>
endfunction

nnoremap <leader>f :call <SID>FindFile()<CR>
