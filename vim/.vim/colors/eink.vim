" E-ink Mono - Monochromatic colorscheme

hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "eink"

" 1. Paleta Monocromática
let s:gui00 = "CCCCCC" " Fondo principal
let s:gui01 = "C2C2C2" " Líneas de números / Fondo suave
let s:gui02 = "AEAEAE" " Selección / Gris claro
let s:gui03 = "868686" " Comentarios / Gris medio
let s:gui04 = "5E5E5E" " Gris oscuro
let s:gui05 = "333333" " Texto principal
let s:gui06 = "474747" " Texto secundario
let s:gui07 = "333333" " Texto fuerte

" Mapeo Cterm (Terminal 256 colores)
let s:cterm00 = "252"
let s:cterm01 = "251"
let s:cterm02 = "249"
let s:cterm03 = "245"
let s:cterm04 = "240"
let s:cterm05 = "236"

" 2. Función de resaltado (Interna del script)
function! s:hi(group, guifg, guibg, ctermfg, ctermbg, attr)
  let l:fg = a:guifg != "" ? " guifg=#" . a:guifg : " guifg=NONE"
  let l:bg = a:guibg != "" ? " guibg=#" . a:guibg : " guibg=NONE"
  let l:cfg = a:ctermfg != "" ? " ctermfg=" . a:ctermfg : " ctermfg=NONE"
  let l:cbg = a:ctermbg != "" ? " ctermbg=" . a:ctermbg : " ctermbg=NONE"
  let l:at = a:attr != "" ? " gui=" . a:attr . " cterm=" . a:attr : " gui=NONE cterm=NONE"
  
  exec "hi " . a:group . l:fg . l:bg . l:cfg . l:cbg . l:at
endfunction

" 3. --- EDITOR UI ---
call s:hi("Normal",     s:gui05, s:gui00, s:cterm05, s:cterm00, "")
call s:hi("Cursor",     s:gui00, s:gui05, s:cterm00, s:cterm05, "")
call s:hi("Visual",     "",      s:gui02, "",        s:cterm02, "")
call s:hi("Search",     s:gui00, s:gui03, s:cterm00, s:cterm03, "italic")
call s:hi("MatchParen", s:gui00, s:gui04, s:cterm00, s:cterm04, "bold")

" Eliminando azules de la UI (~ y carpetas)
call s:hi("NonText",    s:gui02, "",      s:cterm02, "",      "none")
call s:hi("SpecialKey", s:gui02, "",      s:cterm02, "",      "none")
call s:hi("Directory",  s:gui05, "",      s:cterm05, "",      "bold")

" Bordes y números
call s:hi("LineNr",     s:gui03, s:gui01, s:cterm03, s:cterm01, "")
call s:hi("CursorLine", "",      s:gui01, "",        s:cterm01, "none")
call s:hi("CursorLineNr", s:gui05, s:gui01, s:cterm05, s:cterm01, "bold")
call s:hi("VertSplit",  s:gui01, s:gui01, s:cterm01, s:cterm01, "none")

" Barras de estado
call s:hi("StatusLine",   s:gui01, s:gui05, s:cterm01, s:cterm05, "none")
call s:hi("StatusLineNC", s:gui03, s:gui01, s:cterm03, s:cterm01, "none")

" Menú de autocompletado
call s:hi("Pmenu",      s:gui05, s:gui01, s:cterm05, s:cterm01, "none")
call s:hi("PmenuSel",   s:gui01, s:gui05, s:cterm01, s:cterm05, "none")

" 4. --- SINTAXIS MONOCROMÁTICA ---
call s:hi("Comment",    s:gui03, "",      s:cterm03, "",      "italic")
call s:hi("Constant",   s:gui04, "",      s:cterm04, "",      "bold")
call s:hi("String",     s:gui04, "",      s:cterm04, "",      "none")
call s:hi("Character",  s:gui04, "",      s:cterm04, "",      "none")
call s:hi("Number",     s:gui04, "",      s:cterm04, "",      "none")
call s:hi("Boolean",    s:gui04, "",      s:cterm04, "",      "bold")

call s:hi("Identifier", s:gui05, "",      s:cterm05, "",      "none")
call s:hi("Function",   s:gui05, "",      s:cterm05, "",      "bold")
call s:hi("Statement",  s:gui05, "",      s:cterm05, "",      "bold")
call s:hi("PreProc",    s:gui04, "",      s:cterm04, "",      "none")
call s:hi("Type",       s:gui05, "",      s:cterm05, "",      "bold")
call s:hi("Special",    s:gui04, "",      s:cterm04, "",      "none")

call s:hi("Underlined", s:gui05, "",      s:cterm05, "",      "underline")
call s:hi("Todo",       s:gui00, s:gui03, s:cterm00, s:cterm03, "bold")
call s:hi("Error",      s:gui00, s:gui04, s:cterm00, s:cterm04, "bold")

" 5. Limpieza final
delfunction s:hi
