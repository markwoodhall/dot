(let [cmp-nvim-lsp (require :cmp_nvim_lsp)
      lsp-config (require :lspconfig)
      servers ["clojure_lsp" "kotlin_language_server"
               "csharp_ls" "sqlls" "fennel_ls"]
      capabilities (cmp-nvim-lsp.default_capabilities)]
  (each [_ server (pairs servers)]
    (let [config (. lsp-config server)]
      (case server
        "omnisharp" (config.setup {:capabilities capabilities :cmd ["omnisharp"]})
        _ (config.setup {:capabilities capabilities})))))

;; (vim.api.nvim_create_autocmd 
;;   "LspAttach" 
;;   {:callback (fn [args]
;;                (let [client (vim.lsp.get_client_by_id args.data.client_id)]
;;                  (set client.server_capabilities.semanticTokensProvider true)))})

(let [cmp (require :cmp)
      lsp-kind (require :lspkind)
      luasnip (require "luasnip.loaders.from_vscode") ]
  (luasnip.lazy_load)
  (cmp.setup
    {:formatting {:format (lsp-kind.cmp_format)}
     :mapping (cmp.mapping.preset.insert
                {"<C-u>" (cmp.mapping.scroll_docs -4)
                 "<C-d>" (cmp.mapping.scroll_docs 4)
                 "<C-Space>" (cmp.mapping.complete)
                 "<CR>" (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Replace :select true})
                 "<C-j>" (cmp.mapping (fn [fallback]
                                        (if (cmp.visible)
                                          (cmp.select_next_item)
                                          (fallback)))
                                      ["i" "s"])
                 "<C-k>" (cmp.mapping (fn [fallback]
                                          (if (cmp.visible)
                                            (cmp.select_prev_item)
                                            (fallback)))
                                        ["i" "s"])})
     :snippet {:expand (fn [args]
                          (let [ls (require :luasnip)]
                            (ls.lsp_expand args.body)))}
     :sources [{:name "nvim_lsp" :keyword_length 1}
               {:name "path" :keyword_length 3}
               {:name "luasnip"}
               {:name "buffer" :keyword_length 4}]})
  (cmp.setup.filetype 
    "sql"
    {:sources (cmp.config.sources [{:name "vim-dadbod-completion"} 
                                   {:name "luasnip"}
                                   {:name "buffer"}])})
  (cmp.setup.filetype 
    "org"
    {:sources (cmp.config.sources [{:name "orgmode"} 
                                   {:name "luasnip"}
                                   {:name "buffer"}])})
  (cmp.setup.filetype 
    "gitcommit"
    {:sources (cmp.config.sources [{:name "cmp_git"}
                                   {:name "luasnip"}
                                   {:name "conventionalcommits"}
                                   {:name "buffer"}])})
  (cmp.setup.filetype 
    "clojure"
    {:sources (cmp.config.sources [{:name "nvim_lsp" :keyword_length 2}
                                   {:name "async_clj_omni" :keyword_length 3}
                                   {:name "luasnip"}
                                   {:name "buffer" :keyword_length 2}])})
  (cmp.setup.filetype 
    "fennel"
    {:sources (cmp.config.sources [{:name "nvim_lsp" :keyword_length 2}
                                   {:name "luasnip"}
                                   {:name "buffer" :keyword_length 4}])}))
