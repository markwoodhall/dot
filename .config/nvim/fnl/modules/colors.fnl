(let [cat (require "catppuccin")]
  (cat.setup
    {:flavour :mocha
     :color_overrides {:mocha {:base "#11111b"}}
     :background
     {:dark :mocha}
     ;;:term_colors true
     :dim_inactive
     {:enabled false
      :shade "dark"
      :percentage 0.05}
     :integrations
     {:cmp true
      :gitsigns true
      :nvimtree true
      :treesitter true
      :which_key true
      :semantic_tokens true
      :rainbow_delimiters true
      :telescope
      {:enabled true}
      :mini {:enabled true
             :indentscope_color ""}}}))
