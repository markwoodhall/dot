(local cl (require "modules.codelens"))

(fn csharp-codelens []
  (cl.get-blocks 
    "c_sharp"
    "(namespace_declaration) @module
     (method_declaration) @function
     (local_function_statement) @function
     (class_declaration) @type
     (enum_declaration) @type
     (struct_declaration) @type
    (interface_declaration) @type"))

(let [cg (vim.api.nvim_create_augroup "csharp" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "FileType" 
    {:pattern "cs"
     :group cg
     :desc "Setup csharp major mode bindings"
     :callback 
     (fn [])})
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.cs"
     :group cg
     :desc "Setup csharp code lens"
     :callback csharp-codelens}))
