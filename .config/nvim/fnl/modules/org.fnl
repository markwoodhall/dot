(local org {})
(local util (require :util))
(local cl (require "modules.codelens"))
(local vabel (require "modules.vabel"))

(fn org-codelens []
  (cl.get-blocks 
    "org"
    "(headline) @ss"))

(let [og (require "orgmode")]
  ;;(og.setup_ts_grammar)
  (og.setup {:mappings {:disable_all true}}))

(let [ob (require "org-bullets")]
  (ob.setup))

(set org.bind
     (fn []
       (let [wk (require :which-key)]
         (wk.register 
           {:m {:name "org" :buffer (vim.api.nvim_get_current_buf)}
            :me {:name "evaluate" :buffer (vim.api.nvim_get_current_buf)}
            :mt {:name "tangle" :buffer (vim.api.nvim_get_current_buf)}}
           {:prefix " "})
         (util.m-binding "ee" vabel.eval-code-block "eval-code-block")
         (util.m-binding "tt" (fn []
                                (let [file (vim.fn.expand "%:p")]
                                  (vim.cmd (.. "!emacs --batch --eval \"(require 'org)\" --eval '(org-babel-tangle-file \"" file "\")'")))) "emacs-tangle-file"))))

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
