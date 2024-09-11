(comment (let [bbq (require "barbecue")
               bbq-ui (require "barbecue.ui")]
           (bbq.setup
             {:theme :catppucin})
           (bbq-ui.toggle true)))
