(local util (require :util))
(local mvn (require "modules.maven"))

(var cucumber-display-strategy :drawer)
(var cucumber-last-run "")

(fn cucumber-options [test-scenario]
  (let [file (vim.fn.expand "%:p")
        line (util.first (vim.fn.searchpos "Scenario" "bc"))]
    (if test-scenario
      (.. " -Dcucumber.features=\"" file ":" line "\"")
      (.. " -Dcucumber.features=\"" file "\""))))

(fn feature-name-from-current-file []
  (let [current-file (vim.fn.expand "%:p")
        parts (util.split current-file "/")] 
    (. parts (- (length parts) 1))))

(fn glue [_]
  (.. 
    "-Dcucumber.glue=org.crossref.manifold" 
    ""))

(fn test-all []
  (let [target "test-compile integration-test"]
    (set cucumber-last-run target)
    (mvn.run-target target)))

(fn test-feature []
  (let [args (cucumber-options false)
        args (.. args " " (glue (feature-name-from-current-file)))
        target (.. "test-compile test" args)]
    (set cucumber-last-run target)
    (mvn.run-target target)))

(fn test-scenario []
  (let [args (cucumber-options true)
        args (.. args " " (glue (feature-name-from-current-file)))
        target (.. "test-compile test" args)]
    (set cucumber-last-run target)
    (mvn.run-target target)))

(fn test-repeat []
  (mvn.run-target cucumber-last-run))

(fn display [f]
  (match cucumber-display-strategy
    :dispatch (fn [] (vim.cmd (.. "Dispatch -compiler=mvn " (f))))
    :drawer (fn [] (util.drawer-terminal-command (f)))
    :floating (fn [] (util.floating-terminal-command (f)))))

(let [wk (require :which-key)
      cg (vim.api.nvim_create_augroup "feature" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.feature,*.kt"
     :group cg
     :desc "Setup cucumber major mode bindings"
     :callback 
     (fn []
       (wk.add 
         [{1 " m" :group "mode"}
          {1 " mc" :name "cucumber"}])
       (util.m-binding "cr" (display test-repeat) "Repeat cucumber run")
       (util.m-binding "cs" (display test-scenario) "Run cucumber scenario")
       (util.m-binding "ca" (display test-all) "Run all cucumber tests")
       (util.m-binding "cf" (display test-feature) "Run cucumber feature"))}))
