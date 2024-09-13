" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <c-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-j>' 
" -1 for jumping backwards.
inoremap <silent> <c-k> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <c-j> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <c-k> <cmd>lua require('luasnip').jump(-1)<Cr>

" Diff colours
highlight DiffAdd cterm=none ctermfg=black ctermbg=Green
highlight DiffDelete cterm=none ctermfg=black ctermbg=Red
highlight DiffChange cterm=none ctermfg=black ctermbg=Yellow
highlight DiffText cterm=none ctermfg=black ctermbg=Magenta

autocmd BufNewFile,BufRead *.edn,*.cljx,*.cljc,*.cljs,*.cljd setlocal filetype=clojure

" General mappings
nnoremap Q <nop>
nnoremap <j> <j><g>
nnoremap <k> <k><g>
nnoremap ; :
nnoremap <tab> %

"terminal mappings
tnoremap <Esc> <C-\><C-n>
tnoremap <Esc><Esc> <C-\><C-n>:q<CR>

autocmd BufWinEnter,WinEnter term://* normal G

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END

lua << EOF
vim.loader.enable()
local fennel = require("fennel").install()
fennel.path = fennel.path .. ";/home/markwoodhall/.config/nvim/fnl/?.fnl;/home/markwoodhall/.config/nvim/fnl/modules/?.fnl"
pcall(require "init")
EOF
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=20
set isfname-=:
