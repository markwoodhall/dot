(let [cat (require "catppuccin")]
  (cat.setup
    {:flavour :mocha
     :background
     {:dark :mocha}
     :term_colors true
     :integrations
     {:cmp true
      :treesitter true
      :which_key true
      :semantic_tokens true
      :rainbow_delimiters true}}))
