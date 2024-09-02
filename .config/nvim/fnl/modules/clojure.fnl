(local clojure {})
(local util (require "util"))
(local cl (require "modules.codelens"))
(local nvim (require "nvim"))
(local ts-utils (require "nvim-treesitter.ts_utils"))

(fn current-ns []
  (util.first 
    (util.split (util.second (vim.fn.split (vim.fn.getline 1) " ")) ")")))

(fn reloaded-binding [bind action desc]
  (util.m-binding (.. "r" bind) action desc))

(fn eval-binding [bind action desc]
  (util.m-binding (.. "e" bind) action desc))

(fn clojure-codelens []
  (cl.get-blocks 
    "clojure"
    "(source (list_lit) @ll)"))

(set clojure.repl nil)
(set clojure.win nil)
(set clojure.buf nil)

(set vim.g.clojure-jump-to-window false)
(set vim.g.clojure-window-timeout 30000)
(set vim.g.clojure-window-options 
     {:relative :editor
      :border :single
      :anchor :NE
      :row 1
      :col (-> (vim.api.nvim_list_uis)
               (. 1)
               (. :width)) 
      :width 70 
      :height 14})

(fn start-repl []
  (set clojure.last-ns nil)
  (set clojure.buf (vim.api.nvim_create_buf true true))
  (set clojure.win 
       (vim.api.nvim_open_win 
         clojure.buf 
         true 
         vim.g.clojure-window-options))
  (let [root (vim.fn.call "FindRootDirectory" [])
        project-clj (util.exists? (.. root "/project.clj"))
        shadow-cljs (util.exists? (.. root "/shadow-cljs.edn"))
        command (if project-clj 
                  "lein repl"
                  (if shadow-cljs
                    "npx shadow-cljs clj-repl"))
        job (vim.fn.termopen command)]
    (vim.cmd "setlocal norelativenumber")
    (vim.cmd "setlocal nonumber")
    (set nvim.bo.filetype "clojure")
    (set nvim.bo.syntax "clojure")
    {:job job
     :send (fn [data]
             (if clojure.win
               (pcall vim.api.nvim_win_hide (unpack [clojure.win])))
             (set clojure.win 
                  (vim.api.nvim_open_win 
                    clojure.buf 
                    vim.g.clojure-jump-to-window 
                    vim.g.clojure-window-options))
             (vim.fn.chansend job (.. data "\n"))
             (when (> vim.g.clojure-window-timeout 0)
               (set clojure.still-wants-hide false)
               (vim.defer_fn 
                 (fn []
                   (when clojure.still-wants-hide 
                     (pcall vim.api.nvim_win_hide (unpack [clojure.win])))
                   (set clojure.still-wants-hide true)) 
                 vim.g.clojure-window-timeout)))}))

(fn root-expression []
  (let [value (ts-utils.get_node_at_cursor 0 true)
        data (vim.treesitter.get_node_text value 0)]
    data))

(fn dev []
  (let [ns "user"]
    (clojure.in-ns ns)
    ((. clojure.repl :send) "(dev)")))

(fn go []
  (let [ns "dev"]
    (clojure.in-ns ns)
    ((. clojure.repl :send) "(go)")))

(fn reset []
  (let [ns "dev"]
    (clojure.in-ns ns)
    ((. clojure.repl :send) "(reset)")))

(fn stop []
  (let [ns "dev"]
    (clojure.in-ns ns)
    ((. clojure.repl :send) "(stop)")))

(fn system []
  (let [ns "dev"]
    (clojure.in-ns ns)
    ((. clojure.repl :send) "@system")))

(fn reload []
  (let [ns (current-ns)]
    (clojure.in-ns ns)
    ((. clojure.repl :send) (.. "(clojure.core/require '" ns " :reload)"))))

(fn reload-all []
  (let [ns (current-ns)]
    (clojure.in-ns ns)
    ((. clojure.repl :send) (.. "(clojure.core/require '" ns " :reload-all)"))))

(fn shadow-watch [build]
  ((. clojure.repl :send) (.. "(shadow/watch :" build ")")))

(fn shadow-jack [build]
  ((. clojure.repl :send) (.. "(shadow/repl :" build ")")))

(set clojure.setup 
     (fn []
       (let [ts (require :modules.telescope)
             wk (require :which-key)
             paredit (require "modules.paredit")]

         (ts.clojure)

         (util.m-binding "sj" (partial shadow-jack :app)  "hook-into-shadow-repl")
         (util.m-binding "sw" (partial shadow-watch :app)  "start-shadow-build")
         (util.m-binding "si" (fn []
                                (set clojure.repl (start-repl))) "list-jackable-repls")

         (util.m-binding "tp" "RunTests" "Run project tests")

         (eval-binding "e" (fn []
                                (let [e (root-expression)]
                                  (clojure.in-ns)
                                  ((. clojure.repl :send) e))) "Current expression to repl")

         (reloaded-binding "d" dev "dev")
         (reloaded-binding "g" go  "reloaded-go")
         (reloaded-binding "x" reset "reloaded-reset")
         (reloaded-binding "S" stop "reloaded-stop")
         (reloaded-binding "s" system "reloaded-system")
         (reloaded-binding "r" reload "require-ns-with-reload")
         (reloaded-binding "R" reload-all "require-ns-with-reload-all")

         (wk.add 
           [{1 " m" :group "mode"} 
            {1 " mr" :group "reloaded" :buffer (vim.api.nvim_get_current_buf)}
            {1 " me" :group "evaluation" :buffer (vim.api.nvim_get_current_buf)}
            {1 " mt" :group "test" :buffer (vim.api.nvim_get_current_buf)}
            {1 " ms" :group "+sesman" :buffer (vim.api.nvim_get_current_buf)}])

         (paredit.setup))))


(set clojure.last-ns nil)
(set clojure.in-ns 
     (fn [start-ns]
       (when clojure.repl
         (let [ns (or start-ns (current-ns))]
           (when (and ns (not= clojure.last-ns ns))
             ((. clojure.repl :send) (.. "(in-ns '" ns ")"))
             (set clojure.last-ns ns))))))

(let [cg (vim.api.nvim_create_augroup "clojure" {:clear true})]
  (vim.api.nvim_create_autocmd 
    ["BufWinEnter" "BufWritePost"] 
    {:pattern "*.clj,*.cljs,*.cljc"
     :group cg
     :desc "Setup clojure code lens mode bindings"
     :callback clojure-codelens}))

clojure
