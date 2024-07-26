(local util (require :util))

(var dotnet-cmd "dotnet")
(var dotnet-display-strategy :drawer)

(fn wrap-with-env [cmd]
  (let [e (util.read-project-env)]
    (.. e " " cmd)))

(fn in-csproj-dir [cmd]
  (let [d (.. (util.current-project) "/Presentation/Nop.Web")]
    (.. "cd " d " && " cmd)))

(fn clean []
  (-> (.. dotnet-cmd " clean")
      (wrap-with-env)))

(fn compile []
  (-> (.. dotnet-cmd " build")
      (wrap-with-env)))

(fn run []
  (-> (.. dotnet-cmd " run")
      (wrap-with-env)
      (in-csproj-dir)))

(fn display [f strategy]
  (match strategy
    :start (fn [] (vim.cmd (.. "Start " (f))))
    :dispatch-no-compiler (fn [] (vim.cmd (.. "Dispatch " (f))))
    :dispatch (fn [] (vim.cmd (.. "Dispatch -compiler=msbuild " (f))))
    :drawer (fn [] (util.drawer-terminal-command (f)))
    :floating (fn [] (util.floating-terminal-command (f)))))

(let [wk (require :which-key)
      cg (vim.api.nvim_create_augroup "dotnet" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.cs"
     :group cg
     :desc "Setup dotnet major mode bindings"
     :callback 
     (fn []
       (wk.register 
         {:m {:name "mode"
              :d {:name "dotnet"}}}
         {:prefix " "})
       (util.m-binding "dx" (display clean dotnet-display-strategy)  "Clean")
       (util.m-binding "ds" (display run :drawer)  "Run")
       (util.m-binding "dc" (display compile :dispatch)  "Compile"))}))
