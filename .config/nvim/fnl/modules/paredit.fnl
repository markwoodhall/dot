(local paredit {})
(set paredit.setup
     (fn []
       (let [wk (require :which-key)
             wrap (fn [start end]
                    (vim.cmd (.. "call PareditWrap('" start "','" end "')")))]

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

         ;;(vim.keymap.set "n" " sbb" pe.api.barf_backwards {:desc "Barf backwords"})
         ;;(vim.keymap.set "n" " sbf" pe.api.barf_forwards {:desc "Barf forwards"})

         ;;(vim.keymap.set "n" " sdb" pe.api.drag_form_backwards {:desc "Drag backwords"})
         ;;(vim.keymap.set "n" " sdf" pe.api.drag_form_forwards {:desc "Drag forwards"})

         (vim.keymap.set "n" " suu" ":call PareditSplice()<CR>" {:desc "Unwrap form"})
         (vim.keymap.set "n" " sur" ":call PareditRaise()<CR>" {:desc "Raise form"})
         ;;(vim.keymap.set "n" " suR" pe.api.raise_element {:desc "Raise element"})

         (wk.add [{1 " s" :group "smartparens"}
                  {1 " sw" :group "wrap"}
                  {1 " ss" :group "slurp"}
                  {1 " sb" :group "barf"}
                  {1 " sd" :group "drag"}
                  {1 " su" :group "unwrap"}]))))

paredit
