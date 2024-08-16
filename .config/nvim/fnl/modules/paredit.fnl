(local util (require "util"))
(let [pe (require :nvim-paredit)
      ap (require :nvim-autopairs)
      wk (require :which-key)]
  (pe.setup {:cursor_behaviour "follow"})
  (ap.setup {:ignored_next_char []
             :enable_check_bracket_line false})

  (vim.keymap.set "n" " mpw" (fn []
                         (pe.cursor.place_cursor
                           (pe.wrap.wrap_element_under_cursor "( " ")")
                           {:placement "inner_start" :mode "insert"})) {:desc "wrap-element-under-cursor"})
  
  (wk.add [{1 " mp" :group "paredit"}]))
