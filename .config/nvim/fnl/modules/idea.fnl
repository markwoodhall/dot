(local util (require :util))

(var idea-cmd "PATH=\"/usr/lib/jvm/java-20-openjdk/bin/:$PATH\" idea.sh ")
(var idea-display-strategy :dispatch)

(fn inspect [options]
  (let [wd (vim.fn.getcwd)]
    (.. idea-cmd (.. " inspect " wd " " wd "/.idea/inspectionProfiles/Project_Default.xml " wd "/inspection.txt " 
                     "-v0 -d " wd "/src " options
                     " && " 
                     "cat " wd "/inspection.txt"))))

(fn inspect-plain []
  (inspect "-format plain"))

(fn inspect-changes-plain []
  (inspect "-format plain -changes"))

(fn display [f]
  (match idea-display-strategy
    :start (fn [] (vim.cmd (.. "Start " (f))))
    :dispatch-no-compiler (fn [] (vim.cmd (.. "Dispatch " (f))))
    :dispatch (fn [] (vim.cmd (.. "Dispatch -compiler=idea " (f))))
    :drawer (fn [] (util.drawer-terminal-command (f)))
    :floating (fn [] (util.floating-terminal-command (f)))))

(let [wk (require :which-key)
      cg (vim.api.nvim_create_augroup "idea" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.kt,*.java"
     :group cg
     :desc "Setup idea major mode bindings"
     :callback 
     (fn []
       (wk.register 
         {:m {:name "mode"
              :i {:name "idea"}}}
         {:prefix " "})
       (util.m-binding "ii" (display inspect-changes-plain)  "Run idea inspections on changes")
       (util.m-binding "iI" (display inspect-plain)  "Run all idea inspections"))}))
