(let [cat (require "catppuccin")]
  (cat.setup
    {:flavour :mocha
     :background
     {:dark :mocha}
     :term_colors true
     :dim_inactive
     {:enabled false
      :shade "dark"
      :percentage 0.35}
     :integrations
     {:cmp true
      :treesitter true
      :which_key true
      :semantic_tokens true
      :rainbow_delimiters true}}))
