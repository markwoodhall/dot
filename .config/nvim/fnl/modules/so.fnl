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
    (let [args (accumulate 
                 [s ""
                  _ v (ipairs (?. opts :fargs))]
                 (.. s " " v))]
      (util.pane-terminal-command (.. "so " args))))
  {:bang false :desc "So wrapper" :nargs "*"
   :complete completion})

so
