" ============================================================================
" SQL IDE LITE PARA VIM (Inspirado en Dadbod)
" ============================================================================

" Archivos de persistencia
let s:db_list_file = expand('~/.vim/.db_connections')
let s:sidebar_bufname = "__SQL_Connections__"

" Variables globales por defecto
let g:db_perfil = get(g:, 'db_perfil', '')
let g:db_nombre = get(g:, 'db_nombre', '')

" --- SECCIÓN 1: EL EXPLORADOR DE CONEXIONES (SIDEBAR) ---

function! ToggleSQLSpy()
    let l:winid = bufwinnr(s:sidebar_bufname)
    if l:winid != -1
        execute l:winid . "wincmd c"
        return
    endif

    " Crear split vertical a la izquierda
    execute "topleft vnew " . s:sidebar_bufname
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodifiable cursorline
    setlocal winfixwidth width=30
    
    " Mapeos internos del panel
    nnoremap <buffer> <CR> :call <SID>SelectConnection()<CR>
    nnoremap <buffer> a    :call <SID>AddConnection()<CR>
    nnoremap <buffer> d    :call <SID>DeleteConnection()<CR>
    nnoremap <buffer> r    :call <SID>RefreshSidebar()<CR>
    nnoremap <buffer> q    :wincmd c<CR>
    
    call s:RefreshSidebar()
    echo "SQL: [a]ñadir, [d]elete, [Enter] Conectar, [q] Salir"
endfunction

function! s:RefreshSidebar()
    setlocal modifiable
    silent %delete _
    if filereadable(s:db_list_file)
        call setline(1, readfile(s:db_list_file))
    else
        call setline(1, ["# Pulsa 'a' para", "# añadir conexion", "# perfil:base_datos"])
    endif
    setlocal nomodifiable
endfunction

function! s:AddConnection()
    let l:conn = input("Nueva conexión (perfil:base): ")
    if !empty(l:conn) && l:conn =~ ':'
        call writefile([l:conn], s:db_list_file, "a")
        call s:RefreshSidebar()
    else
        echo "\nFormato inválido. Usa 'perfil:base'"
    endif
endfunction

function! s:DeleteConnection()
    let l:line = line('.')
    let l:conns = readfile(s:db_list_file)
    call remove(l:conns, l:line - 1)
    call writefile(l:conns, s:db_list_file)
    call s:RefreshSidebar()
endfunction

function! s:SelectConnection()
    let l:line = getline('.')
    if l:line =~ '^#' | return | endif
    let l:parts = split(l:line, ':')
    if len(l:parts) == 2
        let g:db_perfil = l:parts[0]
        let g:db_nombre = l:parts[1]
        redraw | echo "Conectado a: " . g:db_nombre . " (Perfil: " . g:db_perfil . ")"
    endif
endfunction

" --- SECCIÓN 2: EJECUCIÓN DE QUERIES ---

function! RunSQL() range
    let l:sql = join(getline(a:firstline, a:lastline), "\n")
    if empty(l:sql) | return | endif

    if empty(g:db_perfil) || empty(g:db_nombre)
        echoerr "Error: Selecciona una conexión en el panel lateral (<leader>s) primero."
        return
    endif

    let l:bufname = "__SQL_Result__"
    " 2>&1 captura errores de syntax de MariaDB y los muestra en el buffer
    let l:cmd = "echo " . shellescape(l:sql) . " | mariadb --defaults-group-suffix=" . g:db_perfil . " " . g:db_nombre . " -t 2>&1"
    let l:output = system(l:cmd)

    " Gestionar ventana de resultados
    let l:winid = bufwinnr(l:bufname)
    if l:winid != -1
        execute l:winid . "wincmd w"
    else
        execute "botright 12new " . l:bufname
        setlocal buftype=nofile bufhidden=wipe noswapfile nowrap ft=sql
    endif

    setlocal modifiable
    silent %delete _
    call setline(1, split(l:output, "\n"))
    setlocal nomodifiable
    
    " Volver a la ventana anterior
    wincmd p
endfunction

" --- SECCIÓN 3: MAPEOS Y AUTOCOMANDOS ---

" Abrir el explorador con \s (o tu leader)
nnoremap <leader>s :call ToggleSQLSpy()<CR>

augroup SQL_IDE
    autocmd!
    " Ejecutar con Ctrl+P (p de 'print' o 'play')
    autocmd FileType sql vnoremap <buffer> <C-p> :call RunSQL()<CR>
    autocmd FileType sql nnoremap <buffer> <C-p> vip:call RunSQL()<CR>
    
    " Atajo rápido para ver tablas de la base actual
    autocmd FileType sql nnoremap <buffer> <leader>dt :let g:old_sql=getline('.') <bar> call setline('.', 'SHOW TABLES;') <bar> silent .+call RunSQL() <bar> call setline('.', g:old_sql)<CR>
augroup END
