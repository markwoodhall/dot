(local paredit {})
(set paredit.setup
     (fn []
       (let [pe (require :nvim-paredit)
             ap (require :nvim-autopairs)
             wk (require :which-key)
             wrap (fn [start end]
                    (pe.cursor.place_cursor
                      (pe.wrap.wrap_element_under_cursor start end)
                      {:placement "inner_start" :mode "insert"}))]
         (pe.setup {:cursor_behaviour "follow"})
         (ap.setup {:ignored_next_char []
                    :enable_check_bracket_line false})

         (vim.keymap.set "n" " sw(" (partial wrap "( " ")") {:desc "Wrap with parens"})
         (vim.keymap.set "n" " sw)" (partial wrap "( " ")") {:desc "Wrap with parens"})

         (vim.keymap.set "n" " sw[" (partial wrap "[ " "]") {:desc "Wrap with brackets"})
         (vim.keymap.set "n" " sw]" (partial wrap "[ " "]") {:desc "Wrap with brackets"})

         (vim.keymap.set "n" " sw{" (partial wrap "{ " "}") {:desc "Wrap with braces"})
         (vim.keymap.set "n" " sw}" (partial wrap "[ " "]") {:desc "Wrap with braces"})

         (vim.keymap.set "n" " sw'" (partial wrap "' " "'") {:desc "Wrap with single quotes"})
         (vim.keymap.set "n" " sw}" (partial wrap "\" " "\"") {:desc "Wrap with double quotes"})

         (vim.keymap.set "n" " ssb" pe.api.slurp_backwards {:desc "Slurp backwords"})
         (vim.keymap.set "n" " ssf" pe.api.slurp_forwards {:desc "Slurp forwards"})

         (vim.keymap.set "n" " sbb" pe.api.barf_backwards {:desc "Barf backwords"})
         (vim.keymap.set "n" " sbf" pe.api.barf_forwards {:desc "Barf forwards"})

         (vim.keymap.set "n" " sdb" pe.api.drag_form_backwards {:desc "Drag backwords"})
         (vim.keymap.set "n" " sdf" pe.api.drag_form_forwards {:desc "Drag forwards"})

         (vim.keymap.set "n" " suu" pe.unwrap.unwrap_form_under_cursor {:desc "Unwrap form"})
         (vim.keymap.set "n" " sur" pe.api.raise_form {:desc "Raise form"})
         (vim.keymap.set "n" " suR" pe.api.raise_element {:desc "Raise element"})

         (wk.add [{1 " s" :group "smartparens"}
                  {1 " sw" :group "wrap"}
                  {1 " ss" :group "slurp"}
                  {1 " sb" :group "barf"}
                  {1 " sd" :group "drag"}
                  {1 " su" :group "unwrap"}]))))

paredit
