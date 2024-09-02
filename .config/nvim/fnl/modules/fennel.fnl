(local fennel {})
(local cl (require "modules.codelens"))
(local util (require "util"))
(local nvim (require "nvim"))
(local paredit (require "modules.paredit"))
(local ts-utils (require "nvim-treesitter.ts_utils"))

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

(set fennel.repl nil)
(set fennel.win nil)
(set fennel.buf nil)

(set vim.g.fennel-jump-to-window false)
(set vim.g.fennel-window-timeout 30000)
(set vim.g.fennel-window-options 
     {:relative :editor
      :border :single
      :anchor :NE
      :row 1
      :col (-> (vim.api.nvim_list_uis)
               (. 1)
               (. :width)) 
      :width 70 
      :height 14})

(fn start-repl []
  (set fennel.last-ns nil)
  (set fennel.buf (vim.api.nvim_create_buf true true))
  (set fennel.win 
       (vim.api.nvim_open_win 
         fennel.buf 
         true 
         vim.g.fennel-window-options))
  (let [job (vim.fn.termopen "fennel")]
    (vim.cmd "setlocal norelativenumber")
    (vim.cmd "setlocal nonumber")
    (set nvim.bo.filetype "fennel")
    (set nvim.bo.syntax "fennel")
    {:job job
     :send (fn [data]
             (if fennel.win
               (pcall vim.api.nvim_win_hide (unpack [fennel.win])))
             (set fennel.win 
                  (vim.api.nvim_open_win 
                    fennel.buf 
                    vim.g.fennel-jump-to-window 
                    vim.g.fennel-window-options))
             (vim.fn.chansend job (.. data "\n"))
             (when (> vim.g.fennel-window-timeout 0)
               (set fennel.still-wants-hide false)
               (vim.defer_fn 
                 (fn []
                   (when fennel.still-wants-hide 
                     (pcall vim.api.nvim_win_hide (unpack [fennel.win])))
                   (set fennel.still-wants-hide true)) 
                 vim.g.fennel-window-timeout)))}))

(fn root-expression []
  (let [value (ts-utils.get_node_at_cursor 0 true)
        data (vim.treesitter.get_node_text value 0)]
    data))


(set fennel.setup 
     (fn []
       (let [wk (require :which-key)]
         (util.m-binding "ee" (fn []
                                (let [e (root-expression)]
                                  ((. fennel.repl :send) e))) "Current expression to repl")
         (util.m-binding "si" (fn []
                                (set fennel.repl (start-repl))) "list-jackable-repls")
         (wk.add 
           [{1 " m" :group "mode"} 
            {1 " me" :group "evaluation" :buffer (vim.api.nvim_get_current_buf)}
            {1 " ms" :group "+sesman" :buffer (vim.api.nvim_get_current_buf)}])
         (paredit.setup))))


(let [cg (vim.api.nvim_create_augroup "fennel" {:clear true})]
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.fnl"
     :group cg
     :desc "Setup fennel codelens"
     :callback fennel.fennel-codelens}))

fennel
