(local org {})
(local util (require :util))
(local cl (require "modules.codelens"))
(local vabel (require "modules.vabel"))
(local og (require "orgmode"))

(fn org-codelens []
  (cl.get-blocks 
    "org"
    "(headline) @ss"))

(set org.setup
     (fn []
       (let [wk (require :which-key)
             ob (require "org-bullets")]
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
