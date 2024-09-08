(local chatgpt {})
(local util (require :util))

(set chatgpt.setup 
     (fn []))

(fn completion [_ _]
  (vim.fn.sort
    [:-c :--config :--clear-history :--help :-q :--query :--set-model]))

(vim.api.nvim_create_user_command
  "Chatgpt"
  (fn [opts]
    (let [args (accumulate 
                 [s ""
                  _ v (ipairs (?. opts :fargs))]
                 (.. s " " v))
          tmp (vim.fn.tempname)
          org (.. "/home/markwoodhall/Insync/mark.woodhall@gmail.com/GoogleDrive/notes/markwoodhall/dev/" (string.gsub args "%s+" "-") ".org")]
      (if (util.exists? org)
        (util.pane "org" org false false)
        (do
          (vim.fn.system (.. "chatgpt " args " > " tmp))
          (vim.fn.system (.. "pandoc -f markdown -t org -o " org " " tmp))
          (util.pane "org" org false false)))))
  {:bang false :desc "Chatgpt wrapper" :nargs "*"
   :complete completion})

chatgpt
