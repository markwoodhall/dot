(local Plug (. vim.fn "plug#"))

(vim.call "plug#begin")

(Plug "nvim-tree/nvim-web-devicons")
(Plug "folke/which-key.nvim")
(Plug "hiphish/rainbow-delimiters.nvim")

;; Java / Kotlin
(Plug "markwoodhall/vim-idea" {:for [:java :kotlin]})
(Plug "markwoodhall/maven-compiler.vim" {:for [:java :kotlin]})
(Plug "udalov/kotlin-vim" {:for :kotlin})

;; Better Quick Fix
(Plug "kevinhwang91/nvim-bqf")

;; Directory manipulation
(Plug "stevearc/oil.nvim")

;; Treesitter
(Plug "nvim-treesitter/nvim-treesitter" {:do ":TSUpdate"})
(Plug "nvim-treesitter/playground" {:on "TSPlaygroundToggle"})


;; Org mode
(Plug "nvim-orgmode/orgmode")
(Plug "akinsho/org-bullets.nvim" {:for :org})
(Plug "dhruvasagar/vim-table-mode" {:for :org})

;; Lisp
(Plug "kovisoft/paredit" {:for [:clojure :fennel]})

;; Clojure
(Plug "tpope/vim-fireplace" {:for :clojure})
(set vim.g.fireplace_print_width 80)
(Plug "guns/vim-clojure-static" {:for :clojure})
(Plug "clojure-vim/clojure.vim" {:for :clojure})
(set vim.g.clojure_max_lines 1000)
(Plug "clojure-vim/async-clj-omni" {:for :clojure})
(Plug "markwoodhall/vim-aurepl" {:for :clojure})
(Plug "markwoodhall/vim-cljreloaded" {:for :clojure})

;; Projects
(Plug "airblade/vim-rooter")
(set vim.g.rooter_patterns ["project.clj" "shadow-cljs.edn" "pom.xml" "*.sln"])
(set vim.g.rooter_silent_chdir 1)

;; Version control
(Plug "tpope/vim-fugitive")
(Plug "tpope/vim-rhubarb")

;; Completion & LSP
(Plug "neovim/nvim-lspconfig")
(Plug "SmiteshP/nvim-navic")
(Plug "utilyre/barbecue.nvim")
(Plug "onsails/lspkind.nvim")
(Plug "hrsh7th/nvim-cmp")
(Plug "hrsh7th/cmp-nvim-lsp")
(Plug "petertriho/cmp-git")
(Plug "saadparwaiz1/cmp_luasnip")
(Plug "davidsierradz/cmp-conventionalcommits")
(Plug "hrsh7th/cmp-path")
(Plug "L3MON4D3/LuaSnip")
(Plug "rafamadriz/friendly-snippets")

;; Interface
(Plug "nvim-lualine/lualine.nvim")

(Plug "nvim-lua/plenary.nvim")
(Plug "nvim-telescope/telescope.nvim")
(Plug "stevearc/dressing.nvim")
(Plug "tpope/vim-unimpaired")
(Plug "tpope/vim-surround")
(Plug "tpope/vim-dispatch")
(Plug "tpope/vim-eunuch")
(Plug "radenling/vim-dispatch-neovim")
(Plug "mhinz/vim-signify")
(Plug "lilydjwg/colorizer")
(set vim.g.colorizer_nomap 1)
(set vim.g.colorizer_maxlines 1000)

(Plug "DataWraith/auto_mkdir")
(Plug "ekalinin/Dockerfile.vim")
(Plug "lukas-reineke/indent-blankline.nvim")

;; Database
(Plug "tpope/vim-dadbod" {:on :DBUI})
(Plug "kristijanhusak/vim-dadbod-ui" {:on :DBUI})
(Plug "kristijanhusak/vim-dadbod-completion" {:on :DBUI})
(set vim.g.db_ui_save_location "~/dotfiles")

;; Colors
(Plug "catppuccin/nvim" {:as :catppuccin})

;; Terraform
(Plug "hashivim/vim-terraform")

;;(Plug :junegunn/seoul256.vim)
;;(Plug "https://github.com/junegunn/vim-easy-align.git")
;;(Plug :fatih/vim-go {:tag "*"})
;;(Plug :neoclide/coc.nvim {:branch :release})
;;(Plug :junegunn/fzf {:dir "~/.fzf"})
;;(Plug :junegunn/fzf {:dir "~/.fzf" :do "./install --all"})
;;(Plug :junegunn/fzf {:do (fn [] ((. vim.fn "fzf#install")))})
;;(Plug :nsf/gocode {:rtp :vim})
;;(Plug :preservim/nerdtree {:on :NERDTreeToggle})
;;(Plug :tpope/vim-fireplace {:for :clojure})
;;(Plug "~/my-prototype-plugin")

(vim.call "plug#end")	

(require :modules.core)
(require :modules.bbq)
(require :modules.blankline)
(require :modules.catppucin)
(require :modules.clojure)
(require :modules.codelens)
(require :modules.completion)
(require :modules.csharp)
(require :modules.cucumber)
(require :modules.dotnet)
(require :modules.dressing)
(require :modules.fennel)
(require :modules.idea)
(require :modules.keymap)
(require :modules.kotlin)
(require :modules.lualine)
(require :modules.markdown)
(require :modules.maven)
(require :modules.mono)
(require :modules.notes)
(require :modules.oil)
(require :modules.org)
(require :modules.paredit)
(require :modules.telescope)
(require :modules.treesitter)
(require :modules.vabel)
