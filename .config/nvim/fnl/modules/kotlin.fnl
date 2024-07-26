(local cl (require "modules.codelens"))

(fn kotlin-codelens []
  (cl.get-blocks 
    "kotlin"
    "(function_declaration) @func
    (class_declaration) @class"))

(let [cg (vim.api.nvim_create_augroup "kotlin" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "FileType" 
    {:pattern "kotlin"
     :group cg
     :desc "Setup kotlin major mode bindings"
     :callback 
     (fn [])})
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.kt"
     :group cg
     :desc "Setup kotlin code lens"
     :callback kotlin-codelens}))
