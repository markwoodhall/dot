(local util (require :util))

(var mvn-cmd "mvn -e")
(var mvn-display-strategy :drawer)

(fn wrap-with-env [cmd]
  (let [e (util.read-project-env)]
    (.. e " " cmd)))

(fn clean []
  (-> (.. mvn-cmd " clean")
      (wrap-with-env)))

(fn compile []
  (-> (.. mvn-cmd " clean compile")
      (wrap-with-env)))

(fn compile-all []
  (-> (.. mvn-cmd " clean compile test-compile")
      (wrap-with-env)))

(fn test [args]
  (-> (.. mvn-cmd " clean test " (if args args ""))
      (wrap-with-env)))

(fn integration-test []
  (-> (.. mvn-cmd " clean integration-test")
      (wrap-with-env)))

(fn spring-boot []
  (-> (.. mvn-cmd " clean spring-boot:run")
      (wrap-with-env)))

(fn display [f strategy]
  (match strategy
    :start (fn [] (vim.cmd (.. "Start " (f))))
    :dispatch-no-compiler (fn [] (vim.cmd (.. "Dispatch " (f))))
    :dispatch (fn [] (vim.cmd (.. "Dispatch -compiler=mvn " (f))))
    :drawer (fn [] (util.drawer-terminal-command (f)))
    :floating (fn [] (util.floating-terminal-command (f)))))

(let [wk (require :which-key)
      cg (vim.api.nvim_create_augroup "maven" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.kt,*.feature,*.java"
     :group cg
     :desc "Setup maven major mode bindings"
     :callback 
     (fn []
       (wk.register 
         {:m {:name "mode"
              :m {:name "maven"}}}
         {:prefix " "})
       (util.m-binding "mx" (display clean mvn-display-strategy)  "Clean")
       (util.m-binding "mC" (display compile-all :dispatch)  "Compile all")
       (util.m-binding "mc" (display compile :dispatch)  "Compile")
       (util.m-binding "mt" (display test mvn-display-strategy)  "Run tests")
       (util.m-binding "mT" (display integration-test mvn-display-strategy)  "Run integration test")
       (util.m-binding "ms" (display spring-boot :drawer)  "Run spring boot"))}))
