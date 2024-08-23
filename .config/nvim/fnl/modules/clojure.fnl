(local clojure {})
(local util (require "util"))
(local cl (require "modules.codelens"))

(fn reloaded-binding [bind action desc]
  (util.m-binding (.. "r" bind) action desc))

(fn eval-binding [bind action desc]
  (util.m-binding (.. "e" bind) action desc))

(fn clojure-codelens []
  (cl.get-blocks 
    "clojure"
    "(source (list_lit) @ll)"))

(set clojure.setup 
     (fn []
       (let [ts (require :modules.telescope)
             wk (require :which-key)
             paredit (require "modules.paredit")]
         (util.m-binding "si" ts.repl "list-jackable-repls")
         (util.m-binding "sj" "ShadowJack app" "hook-into-shadow-repl")

         (util.m-binding "tp" "RunTests" "Run project tests")

         (reloaded-binding "a" "CljApropos" "reloaded-apropos")
         (reloaded-binding "c" "ReloadedCleanNsUnderCursor" "reloaded-clean-ns-under-cursor")
         (reloaded-binding "g" "ReloadedGo" "reloaded-go")
         (reloaded-binding "r" "ReloadedReset" "reloaded-reset")
         (reloaded-binding "S" "ReloadedStop" "reloaded-stop")
         (reloaded-binding "s" "ReloadedSystem" "reloaded-system")
         (reloaded-binding "e" "CljExplore" "reloaded-explore-all-namespaces")
         (reloaded-binding "i" "CljInNamespace" "reloaded-switch-to-namespace")
         (reloaded-binding "t" "ReloadedThisNs" "reloaded-switch-to-this-namespace")
         (reloaded-binding "d" "CljDocs" "reloaded-clojure-docs")

         (eval-binding "E" "ExpressionToRepl" "current-expression-to-repl-inline")
         (eval-binding "e" "RootToRepl" "root-expression-to-repl-inline")
         (eval-binding "b" "BufToRepl" "buffer-to-repl-inline")
         (eval-binding "l" "LineToRepl" "line-to-repl-inline")
         (eval-binding "h" "ExpressionHide" "hide-inline-expression-vals")
         (eval-binding "r" "Require" "require-ns-with-reload")
         (eval-binding "R" "Require!" "require-ns-with-reload-all")

         (wk.add 
           [{1 " m" :group "mode"} 
            {1 " mr" :group "reloaded" :buffer (vim.api.nvim_get_current_buf)}
            {1 " me" :group "evaluation" :buffer (vim.api.nvim_get_current_buf)}
            {1 " mt" :group "test" :buffer (vim.api.nvim_get_current_buf)}
            {1 " ms" :group "+sesman" :buffer (vim.api.nvim_get_current_buf)}])
         
         (paredit.setup))))

(let [cg (vim.api.nvim_create_augroup "clojure" {:clear true})]
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.clj,*.cljs,*.cljc"
     :group cg
     :desc "Setup clojure code lens mode bindings"
     :callback clojure-codelens}))

clojure
