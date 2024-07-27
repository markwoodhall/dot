(local util (require :util))

(var msbuild-cmd "msbuild")
(var mono-display-strategy :drawer)

(fn wrap-with-env [cmd]
  (let [e (util.read-project-env)]
    (.. e " " cmd)))

(fn in-csproj-dir [cmd]
  (let [d (.. (util.current-project) "/Abvin.Trading.Web")]
    (.. "cd " d " && " cmd)))

(fn clean []
  (-> (.. msbuild-cmd " -t:Clean")
      (wrap-with-env)))

(fn restore []
  (-> (.. msbuild-cmd " /restore")
      (wrap-with-env)))

(fn compile []
  (-> (.. msbuild-cmd " -t:Rebuild")
      (wrap-with-env)))

(fn run []
  (-> "mono-sgen /usr/lib/mono/4.5/xsp4.exe --address=127.0.0.1 --verbose"
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
      cg (vim.api.nvim_create_augroup "mono" {:clear true})]
  (vim.api.nvim_create_autocmd 
    "BufWinEnter" 
    {:pattern "*.cs,*.cshtml"
     :group cg
     :desc "Setup mono major mode bindings"
     :callback 
     (fn []
       (wk.add
        [{1 " m" :group "mode"} 
         {1 " mm" :group "mono"} 
         {1 " m" :group "mode"}])
       (util.m-binding "mx" (display clean mono-display-strategy)  "Clean")
       (util.m-binding "mr" (display restore mono-display-strategy)  "Restore")
       (util.m-binding "ms" (display run :drawer)  "Run")
       (util.m-binding "mc" (display compile :dispatch)  "Compile"))}))
