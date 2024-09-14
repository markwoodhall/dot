(local Plug (. vim.fn "plug#"))
(vim.call "plug#begin")

;; Install plugins
(do 
  (Plug "nvim-tree/nvim-web-devicons")
  (Plug "folke/which-key.nvim")
  (Plug "hiphish/rainbow-delimiters.nvim" {:for [:clojure :java :kotlin :sql :fennel :lua :vim :bash :javascript]})

  ;; Java / Kotlin
  (Plug "markwoodhall/vim-idea" {:for [:java :kotlin]})
  (Plug "markwoodhall/maven-compiler.vim" {:for [:java :kotlin]})
  (Plug "udalov/kotlin-vim" {:for :kotlin})

  ;; Better Quick Fix
  (Plug "kevinhwang91/nvim-bqf")

  ;; Treesitter
  (Plug "nvim-treesitter/nvim-treesitter" {:do ":TSUpdate" :for [:clojure :fennel :lua :vim :bash :sql :kotlin :javascript :cs :org]})
  ;;(Plug "nvim-treesitter/playground" {:on :TSPlaygroundToggle})

  ;; Org mode
  ;; We should be able to do a :for :org here, but there
  ;; is some kind of plugin issue which means it needs
  ;; loaded always
  (Plug "nvim-orgmode/orgmode")
  (Plug "akinsho/org-bullets.nvim" {:for :org})
  (Plug "dhruvasagar/vim-table-mode" {:for :org})

  ;; Lisp
  (Plug "kovisoft/paredit" {:for [:clojure :fennel]})
  (set vim.g.paredit_leader ",")
  (set vim.g.paredit_matchlines 1000)

  (Plug "jaawerth/fennel.vim" {:for [:fennel]})

  ; Clojure
  (Plug "clojure-vim/clojure.vim" {:for :clojure})
  (set vim.g.clojure_max_lines 1000)

  ;; Projects
  (Plug "airblade/vim-rooter")
  (set vim.g.rooter_patterns ["project.clj" "shadow-cljs.edn" "pom.xml" "*.sln"])
  (set vim.g.rooter_silent_chdir 1)

  ;; Version control
  (Plug "tpope/vim-fugitive" {:on [:G :Git :Gvdiffsplit]})

  ;; Completion & LSP
  (Plug "neovim/nvim-lspconfig")
  ;;(Plug "SmiteshP/nvim-navic" {:for [:clojure :kotlin :sql :fennel :cs]})
  ;;(Plug "utilyre/barbecue.nvim" {:for [:clojure :kotlin :sql :fennel :cs]})
  ;;(Plug "onsails/lspkind.nvim" {:for [:clojure :kotlin :sql :fennel :cs]})
  (Plug "hrsh7th/nvim-cmp")
  (Plug "hrsh7th/cmp-nvim-lsp")
  (Plug "davidsierradz/cmp-conventionalcommits")
  (Plug "hrsh7th/cmp-path")

  ;; Interface
  (Plug "tpope/vim-vinegar")
  (Plug "nvim-lualine/lualine.nvim")

  ;;(Plug "nvim-lua/plenary.nvim")
  ;;(Plug "nvim-telescope/telescope.nvim")
  ;;(Plug "stevearc/dressing.nvim")
  (Plug "tpope/vim-surround")
  (Plug "tpope/vim-dispatch" {:on :Dispatch})
  (Plug "radenling/vim-dispatch-neovim")
  (Plug "tpope/vim-eunuch" {:on :Remove})
  (Plug "lilydjwg/colorizer" {:for [:clojure :org :html :javascript :css :less]})
  (set vim.g.colorizer_nomap 1)
  (set vim.g.colorizer_maxlines 1000)

  ;;(Plug "DataWraith/auto_mkdir")
  (Plug "ekalinin/Dockerfile.vim")
  ;;(Plug "lukas-reineke/indent-blankline.nvim")

  ;; Database
  (Plug "tpope/vim-dadbod" {:on :DBUI})
  (Plug "kristijanhusak/vim-dadbod-ui" {:on :DBUI})
  (Plug "kristijanhusak/vim-dadbod-completion" {:on :DBUI})
  (set vim.g.db_ui_save_location "~/dotfiles")

  ;; Colors
  (Plug "catppuccin/nvim" {:as :catppuccin})

  ;; Terraform
  (Plug "hashivim/vim-terraform"))
(vim.call "plug#end")	

;; Load modules
(do
  (require :modules.colors)
  (require :modules.core)
  (require :modules.completion)
  (require :modules.keymap)
  (require :modules.lualine)
  (require :modules.npm)
  (require :modules.docker)
  (require :modules.aws)
  (require :modules.so)
  (require :modules.chatgpt)
  (require :modules.bw)
  (require :modules.eunuchplus)
  ;; We shouldn't really need to this here
  ;; as org module is loaded for org files, but there
  ;; is some kind of plugin issue which means it needs
  ;; loaded upfront
  (require :modules.org))

(vim.cmd "hi CodeLensReference guifg=#494D64 guibg=#1e1e2e cterm=italic gui=italic")
(vim.cmd "hi WinSeparator guifg=#1e1e2e guibg=#1e1e2e cterm=italic gui=italic")
