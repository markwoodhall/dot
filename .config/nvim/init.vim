lua << EOF
local disabled_built_ins = {
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
EOF

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
