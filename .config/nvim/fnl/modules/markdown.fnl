(local util (require "util"))
(local vabel (require "modules.vabel"))

(let [wk (require :which-key)
      cg (vim.api.nvim_create_augroup "markdown" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufEnter" 
    {:pattern "*.md"
     :group cg
     :desc "Setup markdown major mode bindings"
     :callback 
     (fn []
       (util.which-key-clear-major)
       (wk.add
        [{1 " m" :group "mode"} 
         {1 " me" :group "evaluate"} 
         {1 " mo" :group "export"}])
       (util.m-binding "ee" vabel.eval-code-block "eval-code-block")
       (util.m-binding "op" (fn []
                       (let [file (vim.fn.expand "%:p")
                             out-file (.. file ".pdf")]
                         (vim.cmd (.. "!pandoc --pdf-engine=xelatex -o " out-file " " file)))) "pandoc-xelatex-to-pdf")
       (util.m-binding "ob" (fn []
                       (let [file (vim.fn.expand "%:p")
                             out-file (.. file ".press.pdf")]
                         (vim.cmd (.. "!pandoc --pdf-engine=xelatex -t beamer -o " out-file " " file)))) "pandoc-xelatex-beamer-to-pdf"))}))

