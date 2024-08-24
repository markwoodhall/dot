(let [ts (require "nvim-treesitter.configs")]
  (ts.setup 
    {:ensure_installed 
     ["c" "c_sharp" "fennel" "lua" "vim" 
      "clojure" "bash" "javascript"
      "kotlin" "sql"]
     :ignore_install ["org"]
     :sync_install false
     :auto_install true
     :highlight 
     {:enable true :additional_vim_regex_highlighting []}}))
