(local so {})

(set so.setup 
     (fn []))

(fn completion [_ _]
  (vim.fn.sort
    [:-e :--engine]))

(vim.api.nvim_create_user_command
  "So"
  (fn [opts]
    (let [util (require :util)
          args (util.gather-args opts)]
      (util.pane-terminal-command (.. "so " args))))
  {:bang false :desc "So wrapper" :nargs "*"
   :complete completion})

so
