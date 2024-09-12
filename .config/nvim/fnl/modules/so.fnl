(local so {})
(local util (require :util))

(set so.setup 
     (fn []))

(fn completion [_ _]
  (vim.fn.sort
    [:-e :--engine]))

(vim.api.nvim_create_user_command
  "So"
  (fn [opts]
    (let [args (util.gather-args opts)]
      (util.pane-terminal-command (.. "so " args))))
  {:bang false :desc "So wrapper" :nargs "*"
   :complete completion})

so
