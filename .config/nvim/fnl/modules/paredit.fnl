(let [pe (require :nvim-paredit)
      ap (require :nvim-autopairs)]
  (pe.setup)
  (ap.setup {:ignored_next_char []
             :enable_check_bracket_line false}))
