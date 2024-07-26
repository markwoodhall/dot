(local dressing (require :dressing))

(dressing.setup
  {:select {:enabled true
            :backend ["telescope" "fzf_lua" "fzf" "builtin" "nui"]
            :trim_prompt true
            :telescope {:theme "ivy"}}})
