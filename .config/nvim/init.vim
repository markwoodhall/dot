filetype off

" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <c-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-j>' 
" -1 for jumping backwards.
inoremap <silent> <c-k> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <c-j> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <c-k> <cmd>lua require('luasnip').jump(-1)<Cr>

function! FireplaceConnected()
  if exists('b:fireplace_connected_tries') && (b:fireplace_connected_tries > 1) == 1 && b:fireplace_connected == 0
    return 'unknown'
  endif
  if &filetype == 'clojure'
    if exists('b:fireplace_connected') && b:fireplace_connected == 1
      return 'connected ' .. b:fireplace_connected_port[0]
    endif

    if exists('b:fireplace_connected') && b:fireplace_connected == 0 && exists('g:loaded_fireplace') && g:loaded_fireplace == 1
      let result=''
      try
        let b:fireplace_connected_tries = b:fireplace_connected_tries + 1
        let result = fireplace#session_eval('1')
        try
          let b:fireplace_connected_port = readfile('.nrepl-port')
        catch
          try
            let b:fireplace_connected_port = readfile('.shadow-cljs/nrepl.port')
          catch
            let b:fireplace_connected_port = ''
          endtry
        endtry
        let b:fireplace_connected = 1
      catch
        return 'not connected'
      endtry
    endif 
  endif
endfunction

autocmd BufEnter *.clj,*.cljs if !exists('b:fireplace_connected') | let b:fireplace_connected = 0 | endif
autocmd BufEnter *.clj,*.cljs if exists('b:fireplace_connected') | let b:fireplace_connected = 0 | endif

autocmd BufEnter *.clj,*.cljs if !exists('b:fireplace_connected_tries') | let b:fireplace_connected_tries = 0 | endif
autocmd BufEnter *.clj,*.cljs if exists('b:fireplace_connected_tries') | let b:fireplace_connected_tries = 0 | endif

filetype plugin indent on
syntax on

" Diff colours
highlight DiffAdd cterm=none ctermfg=black ctermbg=Green
highlight DiffDelete cterm=none ctermfg=black ctermbg=Red
highlight DiffChange cterm=none ctermfg=black ctermbg=Yellow
highlight DiffText cterm=none ctermfg=black ctermbg=Magenta

autocmd BufNewFile,BufRead *.edn,*.cljx,*.cljc,*.cljs,*.cljd setlocal filetype=clojure

autocmd BufNewFile,BufRead *.js,*.jsx setlocal filetype=javascript
autocmd BufNewFile,BufRead *.json setlocal filetype=javascript
autocmd BufNewFile,BufRead *.sh setlocal filetype=sh

autocmd BufWritePre *.edn,*.cljs,*.cljc,*.clj,*.cljd :%s/\s\+$//e

" General mappings
nnoremap Q <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <j> <j><g>
nnoremap <k> <k><g>
nnoremap ; :
nnoremap <tab> %
nnoremap <F1> <ESC>
vnoremap <tab> %
vnoremap <F1> <ESC>

inoremap <F1> <ESC>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

"terminal mappings
tnoremap <Esc> <C-\><C-n>
tnoremap <Esc><Esc> <C-\><C-n>:q<CR>

command! -bang -nargs=* ShadowJack execute 'CljEval (shadow/repl :' .. <q-args> .. ')'

autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
autocmd FileType vim setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
autocmd FileType cucumber setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab

autocmd BufWinEnter,WinEnter term://* normal G

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END

lua << EOF


local fennel = require("fennel").install()
fennel.path = fennel.path .. ";/home/markwoodhall/.config/nvim/fnl/?.fnl;/home/markwoodhall/.config/nvim/fnl/modules/?.fnl"
pcall(require "init")

require('elem.statusline')

EOF

nnoremap <leader>br :%s/\s\+$//e<CR>

highlight NormalFloat guibg=#1E1E2E guifg=#CDD6F4
highlight FloatBorder guibg=#1E1E2E guifg=#CDD6F4

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=20
set isfname-=:
