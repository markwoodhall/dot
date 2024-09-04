(local clojure {})
(local util (require "util"))
(local cl (require "modules.codelens"))
(local nvim (require "nvim"))
(local ts-utils (require "nvim-treesitter.ts_utils"))

(fn current-ns []
  (util.first 
    (util.split (util.second (vim.fn.split (vim.fn.getline 1) " ")) ")")))

(fn db-binding [bind action desc]
  (util.m-binding (.. "d" bind) action desc))

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

(fn flip [anchor]
  (match anchor
    :NE (set vim.g.clojure-window-options 
             {:relative :editor
              :border :single
              :anchor :NE
              :row 1
              :col (-> (vim.api.nvim_list_uis)
                       (. 1)
                       (. :width)) 
              :width (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                           (. 1)
                                           (. :width)) 3) 0.5))
              :height (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                            (. 1)
                                            (. :height)) 3) 0.5))})
    :SE (set vim.g.clojure-window-options 
             {:relative :editor
              :border :single
              :anchor :SE
              :row (- (-> (vim.api.nvim_list_uis)
                          (. 1)
                          (. :height)) 8)
              :col (-> (vim.api.nvim_list_uis)
                       (. 1)
                       (. :width)) 
              :width (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                           (. 1)
                                           (. :width)) 3) 0.5))
              :height (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                            (. 1)
                                            (. :height)) 3) 0.5))})
    :NW (set vim.g.clojure-window-options 
         {:relative :editor
          :border :single
          :anchor :NW
          :row 1
          :col 1 
          :width (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                       (. 1)
                                       (. :width)) 3) 0.5))
          :height (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                        (. 1)
                                        (. :height)) 3) 0.5))})
    :SW (set vim.g.clojure-window-options 
         {:relative :editor
          :border :single
          :anchor :SW
          :row (- (-> (vim.api.nvim_list_uis)
                      (. 1)
                      (. :height)) 8)
          :col 1 
          :width (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                       (. 1)
                                       (. :width)) 3) 0.5))
          :height (math.floor (+ (/ (-> (vim.api.nvim_list_uis)
                                        (. 1)
                                        (. :height)) 3) 0.5))})))

(flip :NE)

(fn hide-repl []
  (if clojure.win
    (pcall vim.api.nvim_win_hide (unpack [clojure.win]))))

(fn show-repl [enter]
  (set clojure.win 
       (vim.api.nvim_open_win 
         clojure.buf 
         enter
         vim.g.clojure-window-options)))

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
             (hide-repl)
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
                     (hide-repl))
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

(fn test []
  (let [ns (current-ns)]
    (clojure.in-ns ns)
    ((. clojure.repl :send) (.. "(clojure.test/run-tests '" ns ")"))))

(fn test-all []
  (let [ns (current-ns)]
    (clojure.in-ns ns)
    ((. clojure.repl :send) (.. "(clojure.test/run-all-tests)"))))

(fn init-db []
  (let [ns :dev]
    (clojure.in-ns ns)
    ((. clojure.repl :send) (.. "(use 'db) (db/init-schema)"))))

(fn migrate-db []
  (let [ns :dev]
    (clojure.in-ns ns)
    ((. clojure.repl :send) (.. "(use 'db) (db/migrate-schema)"))))

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

         (util.m-binding "sf" (fn []
                                (hide-repl)
                                (let [c (. vim.g.clojure-window-options :anchor)]
                                  (case c
                                    :NE (flip :SE)
                                    :SE (flip :SW)
                                    :SW (flip :NW)
                                    :NW (flip :NE)))
                                (show-repl false)) "flip-repl")
         (util.m-binding "ss" (partial show-repl true) "jump-to-repl")
         (util.m-binding "sh" hide-repl "hide-repl")
         (util.m-binding "sj" (partial shadow-jack :app)  "hook-into-shadow-repl")
         (util.m-binding "sw" (partial shadow-watch :app)  "start-shadow-build")
         (util.m-binding "si" (fn []
                                (set clojure.repl (start-repl))) "list-jackable-repls")

         (util.m-binding "tb" test "Run buffer tests")
         (util.m-binding "tp" test-all "Run project tests")

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


         (db-binding "i" init-db "init-db")
         (db-binding "m" migrate-db "migrate-db")

         (wk.add 
           [{1 " m" :group "mode"} 
            {1 " mr" :group "reloaded" :buffer (vim.api.nvim_get_current_buf)}
            {1 " me" :group "evaluation" :buffer (vim.api.nvim_get_current_buf)}
            {1 " md" :group "database" :buffer (vim.api.nvim_get_current_buf)}
            {1 " mt" :group "test" :buffer (vim.api.nvim_get_current_buf)}
            {1 " ms" :group "sesman" :buffer (vim.api.nvim_get_current_buf)}])

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
