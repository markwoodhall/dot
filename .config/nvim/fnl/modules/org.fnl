(local org {})

;; Because orgmode internally manages its own treesitter
;; we need to activate it early, otherwise it will cause
;; issue with file previews
;;(og.setup {:mappings {:disable_all true}})

(fn org-codelens []
  (let [cl (require :modules.codelens)]
    (cl.get-blocks 
      "org"
      "(headline) @ss")))

(set org.setup
     (fn []
       (let [wk (require :which-key)
             util (require :util)
             og (require :orgmode)
             ob (require "org-bullets")
             vabel (require :modules.vabel)]
         (og.setup {:mappings {:disable_all true}})
         (ob.setup)
         (wk.add
          [{1 " m" :group "mode"} 
           {1 " me" :group "evaluation"} 
           {1 " mt" :group "tangle"}])
         (util.m-binding "ee" vabel.eval-code-block "eval-code-block")
         (util.m-binding "tt" vabel.tangle-blocks "tangle-file"))))

(let [cg (vim.api.nvim_create_augroup "org" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufEnter" 
    {:pattern "*.org"
     :group cg
     :desc "Setup org mode"
     :callback 
     (fn []
       (vim.cmd ":setlocal conceallevel=0")
       (vim.cmd ":setlocal concealcursor=nc")
       (org-codelens))}))

org
