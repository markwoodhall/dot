(local eunuchplus {})
(local util (require :util))

(set eunuchplus.setup 
     (fn []))

(fn completion [command _ c]
  (let [opts (util.split c " ")
        opt (util.last opts)]
    (if (= opt command)
      (util.glob "./*")
      (util.glob (.. (util.last opts) "*")))))

(vim.api.nvim_create_user_command
  "Tail"
  (fn [opts]
    (let [args (util.gather-args opts)]
      (util.pane-terminal-command (.. "tail " args))))
  {:bang false :desc "Tail wrapper" :nargs "*"
   :complete (partial completion "Tail")})

(vim.api.nvim_create_user_command
  "Grepp"
  (fn [opts]
    (let [args (util.gather-args opts)]
      (util.pane-terminal-command (.. "rg " args))))
  {:bang false :desc "Rg wrapper" :nargs "*"
   :complete (partial completion "Grepp")})

(vim.api.nvim_create_user_command
  "Logs"
  (fn [opts]
    (let [args (util.gather-args opts)]
      (util.pane-terminal-command (.. "tail " args))
      (vim.cmd "setlocal syntax=json")))
  {:bang false :desc "Tail wrapper" :nargs "*"
   :complete (partial completion "Logs")})

eunuchplus
