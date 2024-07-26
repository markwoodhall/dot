(local fennel {})
(local util (require :util))
(local cl (require "modules.codelens"))

(fn binding [bind action desc]
  (vim.keymap.set 
    "n" 
    (.. " m" bind) 
    (if (= (type action) "string") (.. ":" action "<CR>") action) 
    {:desc desc :buffer (vim.api.nvim_get_current_buf)}))

(fn eval-binding [bind action desc]
  (binding (.. "e" bind) action desc))

(set fennel.fennel-codelens 
     (fn []
       (cl.get-blocks 
         "fennel"
         "(fn_form
            (symbol)
            (symbol)
            (sequence_arguments)) @expression")))

(let [wk (require :which-key)
      cg (vim.api.nvim_create_augroup "fennel" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufEnter" 
    {:pattern "*.fnl"
     :group cg
     :desc "Setup fennel major mode bindings"
     :callback 
     (fn []
       (util.which-key-clear-major)
       (wk.register 
         {:m {:name "fennel"}
          :me {:name "evaluation"}}
         {:prefix " "})
       (eval-binding "e" "ConjureEvalRootForm" "current-expression-to-repl")
       (eval-binding "E" "ConjureEvalCurrentForm" "root-expression-to-repl")
       (eval-binding "b" "ConjureEvalBuf" "buf-to-repl"))})
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.fnl"
     :group cg
     :desc "Setup fennel codelens"
     :callback fennel.fennel-codelens}))

