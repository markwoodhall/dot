(let [cg (vim.api.nvim_create_augroup "go" {:clear true})]
 (vim.api.nvim_create_autocmd 
    "BufWritePre" 
    {:pattern "*.go"
     :group cg
     :desc "Setup go"
     :callback (fn []
                 (vim.lsp.buf.code_action
                   {:context {:only ["source.organizeImports"]}
                    :apply true}))}))


