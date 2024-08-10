filetype off
set guifont=JetBrains\ Mono\ ExtraLight:h10
let g:neovide_cursor_animation_length = 0

call plug#begin('~/.vim/plugged')

Plug 'SmiteshP/nvim-navic'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'utilyre/barbecue.nvim'
Plug 'guns/vim-sexp'
let g:sexp_filetypes='clojure,fennel'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'folke/which-key.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/playground'
Plug 'hiphish/rainbow-delimiters.nvim'

Plug 'markwoodhall/vim-idea'
Plug 'markwoodhall/maven-compiler.vim'
Plug 'kevinhwang91/nvim-bqf'
Plug 'stevearc/oil.nvim'

" Org
Plug 'nvim-orgmode/orgmode'
Plug 'akinsho/org-bullets.nvim'
Plug 'dhruvasagar/vim-table-mode'

" Clojure
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
let g:fireplace_print_width=80
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }
Plug 'clojure-vim/clojure.vim', { 'for': 'clojure' }
let g:clojure_maxlines=1000
Plug 'clojure-vim/async-clj-omni', { 'for': 'clojure' }
"
" Mine
Plug 'markwoodhall/vim-aurepl', { 'for': 'clojure' }
Plug 'markwoodhall/vim-cljreloaded', { 'for': 'clojure' }
Plug 'markwoodhall/vim-cljdocs', { 'for': 'clojure' }

Plug 'airblade/vim-rooter'
let g:rooter_patterns = ['project.clj', 'shadow-cljs.edn', 'pom.xml', '*.sln']
let g:rooter_silent_chdir = 1

" Version control
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-grepper'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'petertriho/cmp-git'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'davidsierradz/cmp-conventionalcommits'
Plug 'hrsh7th/cmp-path'
Plug 'L3MON4D3/LuaSnip'
Plug 'dense-analysis/ale'
let g:ale_linters_explicit = 1
let g:ale_linters = {'kotlin': ['ktlint']}
let g:ale_fixers_explicit = 1
let g:ale_fixers = {'kotlin': ['ktlint']}
let g:ale_kotlin_ktlint_options = '-l none'

"Plug 'github/copilot.vim'
" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <c-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-j>' 
" -1 for jumping backwards.
inoremap <silent> <c-k> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <c-j> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <c-k> <cmd>lua require('luasnip').jump(-1)<Cr>

Plug 'rafamadriz/friendly-snippets'
Plug 'udalov/kotlin-vim'
Plug 'nvim-lualine/lualine.nvim'

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

" scss
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'stevearc/dressing.nvim'
Plug 'xolox/vim-misc'

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-rhubarb'
Plug 'mhinz/vim-signify'
Plug 'lilydjwg/colorizer'
let g:colorizer_nomap=1
let g:colorizer_maxlines=1000
Plug 'tmhedberg/matchit'
Plug 'DataWraith/auto_mkdir'
Plug 'ekalinin/Dockerfile.vim'
Plug 'lukas-reineke/indent-blankline.nvim'

" Database
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'

let g:db_ui_save_location='~/dotfiles/' 

" Colours
Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
Plug 'olimorris/onedarkpro.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nyoom-engineering/oxocarbon.nvim', { 'as': 'oxocarbon' }
Plug 'Mofiqul/dracula.nvim'
Plug 'folke/tokyonight.nvim'

" Terraform
Plug 'hashivim/vim-terraform'

Plug 'Olical/aniseed'
" Add plugins to &runtimepath
call plug#end()

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
inoremap {      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}
inoremap if( if (

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

let g:aniseed#env = v:true

lua << EOF

require('aniseed.env').init()
require('elem.statusline')

EOF

nnoremap <leader>br :%s/\s\+$//e<CR>

highlight NormalFloat guibg=#1E1E2E guifg=#CDD6F4
highlight FloatBorder guibg=#1E1E2E guifg=#CDD6F4

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=20
set isfname-=:
