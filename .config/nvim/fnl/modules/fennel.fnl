(local fennel {})
(local cl (require "modules.codelens"))
(local paredit (require "modules.paredit"))
(local util (require "util"))

(fn window-printer [data]
  (let [data (util.but-last data)
        buff (vim.api.nvim_create_buf false true)
        _ (vim.api.nvim_open_win buff true {:relative :cursor :row 0 :col 1 :width 100 :height (length data)})]
    (vim.api.nvim_buf_set_option buff "filetype" "fennel")
    (vim.api.nvim_buf_set_lines buff 0 -1 false data)))

(set fennel.repl nil)

(set fennel.fennel-codelens 
     (fn []
       (cl.get-blocks 
         "fennel"
         "(program (_
            (symbol)
            (binding_pair)) @expression)")
       (cl.get-blocks 
         "fennel"
         "(program (fn_form
            (symbol)
            (symbol)
            (sequence_arguments)) @expression)")))

(set fennel.setup 
     (fn []
       (let [wk (require :which-key)]
         (util.m-binding "si" (fn []
                                (set fennel.repl (fennel.start-repl window-printer))) "list-jackable-repls"
         (util.m-binding "ee" (fn []
                                (let [e (fennel.expression)]
                                  ((. fennel.repl :send) e))) "Current expression to repl")
         (wk.add 
           [{1 " m" :group "mode"} 
            {1 " me" :group "evaluation" :buffer (vim.api.nvim_get_current_buf)}
            {1 " ms" :group "+sesman" :buffer (vim.api.nvim_get_current_buf)}])
         (paredit.setup)))))

(set fennel.start-repl
     (fn [printer]
       (let [job (vim.fn.jobstart 
                   ["bash" "-c" "fennel"]
                   {:on_stderr (fn [_job-id data _event] (print (util.join data " ")))
                    :on_stdout (fn [_job-id data _event]
                                 (printer data))})]
         {:job job
          :send (fn [data]
                  (vim.fn.chansend job (.. data "\n")))})))

(set fennel.expression
     (fn []
       (util.join (util.code-block "(" ")") "\n")))

(let [cg (vim.api.nvim_create_augroup "fennel" {:clear true})]
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.fnl"
     :group cg
     :desc "Setup fennel codelens"
     :callback fennel.fennel-codelens}))

fennel
