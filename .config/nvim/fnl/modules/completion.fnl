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

(let [cmp (require :cmp)]
  (cmp.setup
    {:mapping (cmp.mapping.preset.insert
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
     :sources [{:name "nvim_lsp" :keyword_length 1}
               {:name "path" :keyword_length 3}
               {:name "buffer" :keyword_length 4}]})
  (cmp.setup.filetype 
    "sql"
    {:sources (cmp.config.sources [{:name "vim-dadbod-completion"} 
                                   {:name "buffer"}])})
  (cmp.setup.filetype 
    "org"
    {:sources (cmp.config.sources [{:name "orgmode"} 
                                   {:name "buffer"}])})
  (cmp.setup.filetype 
    "gitcommit"
    {:sources (cmp.config.sources [{:name "cmp_git"}
                                   {:name "conventionalcommits"}
                                   {:name "buffer"}])})
  (cmp.setup.filetype 
    "clojure"
    {:sources (cmp.config.sources [{:name "nvim_lsp" :keyword_length 2}
                                   {:name "buffer" :keyword_length 2}])})
  (cmp.setup.filetype 
    "fennel"
    {:sources (cmp.config.sources [{:name "nvim_lsp" :keyword_length 2}
                                   {:name "buffer" :keyword_length 4}])}))
