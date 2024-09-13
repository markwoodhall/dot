(local eunuchplus {})

(set eunuchplus.setup 
     (fn []))

(fn completion [command _ c]
  (let [util (require :util)
        opts (util.split c " ")
        opt (util.last opts)]
    (if (= opt command)
      (util.glob "./*")
      (util.glob (.. (util.last opts) "*")))))

(vim.api.nvim_create_user_command
  "Tail"
  (fn [opts]
    (let [util (require :util)
          args (util.gather-args opts)]
      (util.pane-terminal-command (.. "tail " args))))
  {:bang false :desc "Tail wrapper" :nargs "*"
   :complete (partial completion "Tail")})

(vim.api.nvim_create_user_command
  "Grep"
  (fn [opts]
    (let [util (require :util)
          args (util.gather-args opts)]
      (util.pane-terminal-command (.. "rg " args))))
  {:bang false :desc "Rg wrapper" :nargs "*"
   :complete (partial completion "Grep")})

(vim.api.nvim_create_user_command
  "Rg"
  (fn [opts]
    (let [util (require :util) 
          args (util.gather-args opts)]
      (vim.cmd (.. "silent grep " args " | copen "))))
  {:bang false :desc "Rg wrapper" :nargs "*"
   :complete (fn [_ opts]
               (let [util (require :util)
                     args (util.last (util.split opts " "))]
                 (vim.cmd (.. "silent grep " args " | copen | redraw!")))
               [])})

(vim.api.nvim_create_user_command
  "Logs"
  (fn [opts]
    (let [util (require :util)
          args (util.gather-args opts)]
      (util.pane-terminal-command (.. "tail " args))
      (vim.cmd "setlocal syntax=json")))
  {:bang false :desc "Tail wrapper" :nargs "*"
   :complete (partial completion "Logs")})

(vim.api.nvim_create_user_command
  "Buffers"
  (fn [_]
    (let [bufnrs (vim.fn.range 1 (vim.fn.bufnr "$"))
          bufnames (icollect [_ v (ipairs bufnrs)]
                     (when (not= (vim.fn.buflisted v) 0) 
                       (let [name (vim.fn.bufname v)]
                         (when (not= name "")
                           {:filename name
                            :lnum 1
                            :text v}))))]
      (vim.fn.setloclist 0 bufnames)
      (vim.cmd "lopen")))
  {:bang false :desc "buffer wrapper" :nargs "*"
   :complete (fn [])})

eunuchplus
