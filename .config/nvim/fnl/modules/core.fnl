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
(nvim.ex.set :ignorecase)
(nvim.ex.set :smartcase)

(set nvim.g.mapleader " ")
(set nvim.g.maplocalleader ",")
(vim.cmd "set path+=**")
(vim.cmd "set wildignore+=**/node_modules/**")
(vim.cmd "set wildignore+=**/.git/**")
(vim.cmd "set wildignore+=**/.clj-kondo/**")
(vim.cmd "set wildignore+=**/cljs-test-runner-out/**")
(vim.cmd "set wildignore+=**/.cpcache/**")
(vim.cmd "set wildignore+=**/.lsp/**")
(vim.cmd "set wildignore+=**/oil:/**")
(vim.cmd "set wildignore+=**/fugitive:/**")
(vim.cmd "set wildignore+=**/target/**")

(vim.cmd "set grepprg=rg\\ --vimgrep")
(vim.cmd "set grepformat^=%f:%l:%c:%m")

(vim.cmd "autocmd FileType qf wincmd J")
(vim.cmd "autocmd FileType qf nmap <buffer> <cr> <cr>:lcl<cr>:ccl<cr>")
(vim.cmd "au BufWritePre,FileWritePre * if @% !~# '\\(://\\)' | call mkdir(expand('<afile>:p:h'), 'p') | endif")

(vim.cmd "colorscheme catppuccin-mocha")
(nvim.ex.set :list)

(vim.cmd "autocmd TermOpen * setlocal scrollback=20000")

(set vim.g.recent_files [])

(let [cg (vim.api.nvim_create_augroup "all" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufRead" 
    {:pattern "*.*"
     :group cg
     :desc "Setup recent files"
     :callback 
     (fn []
       (let [util (require :util)
             old (icollect [_ v (ipairs vim.v.oldfiles)]
                   (when (< (util.count-matches v "BqfPreview*") 1)
                     {:filename v :lnum 1 :text ""}))
             recent [(unpack vim.g.recent_files) (unpack old)]]
         (set vim.g.recent_files [{:filename (vim.fn.expand "%:p") :lnum 1 :text ""} (unpack recent)])))})
  (vim.api.nvim_create_autocmd 
    "VimEnter" 
    {:group cg
     :desc "Setup recent files"
     :callback 
     (fn []
       (let [util (require :util)]
         (set vim.g.recent_files (icollect [_ v (ipairs vim.v.oldfiles)]
                                   (when (< (util.count-matches v "BqfPreview*") 1)
                                     {:filename v :lnum 1 :text ""})))))})
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.*"
     :group cg
     :desc "Setup filetype"
     :callback 
     (fn []
       (let [util (require :util)
             tree (require :modules.treesitter)]
         (util.which-key-clear-major)
         (match nvim.bo.filetype
           "sql" (tree.setup)
           "clojure" (let [clj (require :modules.clojure)] 
                       (tree.setup)
                       (clj.setup))
           "fennel" (let [fnl (require :modules.fennel)] 
                      (tree.setup)
                      (fnl.setup))
           "org" (let [org (require :modules.org)] 
                   (tree.setup)
                   (org.setup)))))})
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
       (match nvim.bo.filetype
           "clojure" nil
           "kotlin" (let [cl (require :modules.codelens)] (cl.get-blocks nvim.bo.filetype nil)) 
           "fennel" (let [cl (require :modules.codelens)] (cl.get-blocks nvim.bo.filetype nil)) 
           _ nil))}))

