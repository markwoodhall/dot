(local nvim (require "nvim"))

;;(set nvim.o.colorcolumn "80")
(set nvim.o.mouse "a")
(set nvim.o.updatetime 500)
(set nvim.o.timeoutlen 500)
(set nvim.o.laststatus 3)
(set nvim.o.textwidth 0)
(set nvim.o.wrapmargin 0)
(set nvim.o.shiftwidth 4)
(set nvim.o.tabstop 4)
(set nvim.o.softtabstop 4)
(set nvim.o.tabline "0")
(set nvim.o.synmaxcol 9999)
(set nvim.o.completeopt "menu,menuone,noselect")
(set nvim.o.background "dark")
(set nvim.o.shell "zsh")
(set nvim.o.fileformat "unix")
(set nvim.o.fileformats "unix,dos")
(set nvim.o.clipboard "unnamedplus")
(set nvim.o.foldmethod "manual")
(set nvim.o.inccommand :nosplit)
(set nvim.o.encoding "utf-8")
(set nvim.o.signcolumn "number")
(set nvim.o.guifont "JetBrains Mono:h11") 
(set nvim.o.cmdheight 0) 

(nvim.ex.set :ruler)
(nvim.ex.set :undofile)
(nvim.ex.set :incsearch)
(nvim.ex.set :noshowmatch)
(nvim.ex.set :noshowmode)
(nvim.ex.set :showcmd)
(nvim.ex.set :hlsearch)
(nvim.ex.set :nowrap)
(nvim.ex.set :splitbelow)
(nvim.ex.set :hidden)
(nvim.ex.set :wildmenu)
(nvim.ex.set :expandtab)
(nvim.ex.set :lazyredraw)
(nvim.ex.set :nospell)
(nvim.ex.set :list)
(nvim.ex.set :relativenumber)
(nvim.ex.set :termguicolors)

(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader ",")
(nvim.ex.colorscheme :catppuccin-mocha)
(nvim.ex.set :list)

(set nvim.o.guicursor "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175")

(vim.cmd "autocmd TermOpen * setlocal scrollback=20000")

(let [cg (vim.api.nvim_create_augroup "all" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.*"
     :group cg
     :desc "Setup filetype"
     :callback 
     (fn []
       (let [util (require :util)]
         (util.which-key-clear-major)
         (match nvim.bo.filetype
           "clojure" (let [clj (require :modules.clojure)] (clj.setup))
           "fennel" (let [fnl (require :modules.fennel)] (fnl.setup))
           "org" (let [org (require :modules.org)] (org.setup)))))})
  (vim.api.nvim_create_autocmd 
    ["BufWritePre"] 
    {:pattern "*.*"
     :group cg
     :desc "Lua format on save"
     :callback 
     (fn []
       (vim.lsp.buf.format))})
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.*"
     :group cg
     :desc "Setup generic codelens"
     :callback 
     (fn []
       (let [cl (require :modules.codelens)]
         (match nvim.bo.filetype
           "clojure" nil
           "kotlin" (cl.get-blocks nvim.bo.filetype nil)
           "fennel" (cl.get-blocks nvim.bo.filetype nil)
           _ (cl.get-blocks nvim.bo.filetype nil))))}))
