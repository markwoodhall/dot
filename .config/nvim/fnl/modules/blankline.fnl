(local nvim (require "aniseed.nvim"))

(let [bl (require :ibl)]
  (bl.setup))

(set nvim.g.indent_blankline_context_patterns 
     ["class"
      "function"
      "method"
      "^if"
      "^while"
      "^typedef"
      "^for"
      "^object"
      "^table"
      "block"
      "arguments"
      "typedef"
      "while"
      "^public"
      "return"
      "if_statement"
      "else_clause"
      "jsx_element"
      "jsx_self_closing_element"
      "try_statement"
      "catch_clause"
      "import_statement"
      "labeled_statement"
      "lit$"])
