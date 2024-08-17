(local fennel {})
(local cl (require "modules.codelens"))
(local paredit (require "modules.paredit"))

(set fennel.fennel-codelens 
     (fn []
       (cl.get-blocks 
         "fennel"
         "(fn_form
            (symbol)
            (symbol)
            (sequence_arguments)) @expression")))

(set fennel.setup 
     (fn []
       (let [pe (require :nvim-paredit-fennel)]
         (paredit.setup)
         (pe.setup))))

(let [cg (vim.api.nvim_create_augroup "fennel" {:clear true})]
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.fnl"
     :group cg
     :desc "Setup fennel codelens"
     :callback fennel.fennel-codelens}))

fennel
