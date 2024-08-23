(var my-paredit-loaded false)
(local paredit {})
(set paredit.setup
     (fn []
       (let [wk (require :which-key)
             wrap (fn [start end]
                    (vim.cmd (.. "call PareditWrap('" start "','" end "')")))]

         (when (not my-paredit-loaded)
           (vim.cmd "call PareditToggle()")
           (set vim.g.paredit_electric_return 0)

           (vim.keymap.set "n" " sw(" (partial wrap "(" ")") {:desc "Wrap with parens"})
           (vim.keymap.set "n" " sw)" (partial wrap "(" ")") {:desc "Wrap with parens"})

           (vim.keymap.set "n" " sw[" (partial wrap "[" "]") {:desc "Wrap with brackets"})
           (vim.keymap.set "n" " sw]" (partial wrap "[" "]") {:desc "Wrap with brackets"})

           (vim.keymap.set "n" " sw{" (partial wrap "{" "}") {:desc "Wrap with braces"})
           (vim.keymap.set "n" " sw}" (partial wrap "[" "]") {:desc "Wrap with braces"})

           (vim.keymap.set "n" " sw'" (partial wrap "\' " "\'") {:desc "Wrap with single quotes"})
           (vim.keymap.set "n" " sw\"" (partial wrap "\" " "\"") {:desc "Wrap with double quotes"})

           (vim.keymap.set "n" " ssb" ":call PareditMoveLeft()<CR>" {:desc "Slurp backwords"})
           (vim.keymap.set "n" " ssf" ":call PareditMoveRight()<CR>" {:desc "Slurp forwards"})

           (vim.keymap.set "n" " suu" ":call PareditSplice()<CR>" {:desc "Unwrap form"})
           (vim.keymap.set "n" " sur" ":call PareditRaise()<CR>" {:desc "Raise form"}))

         (set my-paredit-loaded true)
         (wk.add [{1 "I" :hidden true}
                  {1 " s" :group "smartparens"}
                  {1 " sw" :group "wrap"}
                  {1 " ss" :group "slurp"}
                  {1 " sb" :group "barf"}
                  {1 " sd" :group "drag"}
                  {1 " su" :group "unwrap"}]))))

paredit
