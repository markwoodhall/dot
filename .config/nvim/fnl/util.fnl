(local util {})
(local nvim (require "nvim"))

(set util.expand 
     (fn [path]
       (nvim.fn.expand path)))

(set util.split 
     (fn [s pattern]
       (if s
         (nvim.fn.split s pattern "g")
         [])))

(set util.join 
     (fn [c separator]
       (nvim.fn.join c separator)))

(set util.first 
     (fn [c]
       (?. c 1)))

(set util.second 
     (fn [c]
       (?. c 2)))

(set util.nth 
     (fn [c n]
       (?. c n)))

(set util.last 
     (fn [c]
       (?. c (length c))))

(set util.last-but-1
     (fn [c]
       (?. c (- (length c) 1))))

(set util.empty 
     (fn [c]
       (= (length c) 0)))

(set util.take 
     (fn [c i]
       (table.move c 1 i 1 [])))

(set util.rest 
     (fn [c]
       (table.move c 2 (- (length c) 1) 1 [])))

(set util.take-after 
     (fn [c i after]
       (table.move c after i 1 [])))

(set util.but-last 
     (fn [c]
       (util.take c (- (length c) 1))))

(set util.distinct 
     (fn [c]
       (if c
         (accumulate 
           [t [] _ v (ipairs c)]
           (do 
             (when (util.empty (icollect [_ e (ipairs t)]
                            (if (= e v)
                              v)))
               (table.insert t v))
             t)))))

(set util.fill-string 
     (fn [s n]
       (var x "")
       (for [_ 1 n]
         (set x (.. x s)))
       x))

(set util.split-once 
     (fn [s pattern]
       (let [parts (nvim.fn.split s pattern "g")] 
         [(. parts 1) (util.join (table.move parts 2 (length parts) 1 []) pattern)])))

(set util.glob 
     (fn [path]
       (nvim.fn.glob path true true true)))

(set util.exists? 
     (fn [path]
       (= (nvim.fn.filereadable path) 1)))

(set util.dir-exists? 
     (fn [path]
       (= (nvim.fn.isdirectory path) 1)))

(set util.lua-file 
     (fn [path]
       (nvim.ex.luafile path)))

(set util.count-matches 
     (fn [s pattern]
       (var c 0)
       (each [_ (string.gmatch s pattern)]
         (set c (+ 1 c)))
       c))

(set util.config-path (nvim.fn.stdpath "config"))

(set util.nnoremap 
     (fn [from to desc]
       (nvim.set_keymap
         :n
         (.. "<leader>" from)
         (.. ":" to "<cr>")
         {:noremap true :desc desc})))

(set util.m-binding 
     (fn [bind action desc]
       (vim.keymap.set 
         "n" 
         (.. " m" bind) 
         (if (= (type action) "string") (.. ":" action "<CR>") action) 
         {:desc desc :buffer (vim.api.nvim_get_current_buf)})))

(set util.pane 
     (fn [filetype content listed scratch]
       (vim.cmd "wincmd n")
       (let [_ (vim.api.nvim_create_buf listed scratch)]
         (set nvim.bo.filetype filetype)
         (when (or (= filetype "markdown")
                   (= filetype "org"))
           (vim.cmd "setlocal wrap"))
         (if scratch
           (when (not= content "") 
             (vim.api.nvim_buf_set_lines
               0
               0 -1
               false
               (util.split content "\\n")))
           (when (not= content "") (vim.cmd (.. "e " content))))
         (vim.cmd "wincmd J")
         (vim.cmd "15wincmd_"))))

(var drawer-buf nil)
(set util.drawer 
     (fn [filetype content listed scratch]
       (vim.cmd "wincmd n")
       (when (and (not= drawer-buf nil) (> (vim.fn.bufexists drawer-buf) 0))
         (vim.api.nvim_buf_delete drawer-buf {:force true}))
       (let [buf (vim.api.nvim_create_buf listed scratch)]
         (set drawer-buf buf)
         (set nvim.bo.filetype filetype)
         (when (or (= filetype "markdown")
                   (= filetype "org"))
           (vim.cmd "setlocal wrap"))
         (if scratch
           (when (not= content "") 
             (vim.api.nvim_buf_set_lines
               0
               0 -1
               false
               (util.split content "\\n")))
           (when (not= content "") (vim.cmd (.. "e " content))))
         (vim.cmd "wincmd J")
         (vim.cmd "12wincmd_"))))

(var last-drawer-command "")
(set util.drawer-terminal-command 
     (fn [command]
       (util.drawer "" "" true true)
       (vim.fn.termopen command)
       (set drawer-buf (vim.api.nvim_get_current_buf))
       (vim.cmd "setlocal norelativenumber")
       (vim.cmd "setlocal number")
       (vim.cmd "setlocal filetype=off")
       (vim.cmd "setlocal syntax=off")
       ;; (vim.fn.feedkeys "G")
       (set last-drawer-command command)))

(set util.rerun-last-drawer-command 
     (fn []
       (util.drawer-terminal-command last-drawer-command)))

(var last-pane-command "")
(set util.pane-terminal-command 
     (fn [command]
       (util.pane "" "" true true)
       (vim.fn.termopen command)
       (vim.cmd "setlocal norelativenumber")
       (vim.cmd "setlocal number")
       (vim.cmd "setlocal nowrap")
       (vim.cmd "setlocal filetype=off")
       (vim.cmd "setlocal syntax=off")
       ;; (vim.fn.feedkeys "G")
       (set last-pane-command command)))

(set util.rerun-last-pane-command 
     (fn []
       (util.pane-terminal-command last-pane-command)))

(set util.floating-window 
     (fn [filetype content listed scratch]
       (let [buf (vim.api.nvim_create_buf listed scratch)
             ui (. (vim.api.nvim_list_uis) 1)
             margin 50
             win (vim.api.nvim_open_win
                   buf true {:relative "editor"
                             :border "rounded"
                             :row 1 
                             :col (- (/ (. ui :width) 2) (/ (- (. ui :width) margin) 2))
                             :width (- (. ui :width) margin) :height (- (. ui :height) 10)})]
         (set nvim.bo.filetype filetype)
         (when (or (= filetype "markdown")
                   (= filetype "org"))
           (vim.cmd "setlocal wrap"))
         (if scratch
           (when (not= content "") 
             (vim.api.nvim_buf_set_lines
               0
               0 -1
               false
               (util.split content "\\n")))
           (when (not= content "") (vim.cmd (.. "e " content))))
         win)))

(set util.floating-terminal-command 
     (fn [command]
       (util.floating-window "" "" true true)
       (vim.cmd "setlocal norelativenumber")
       (vim.cmd "setlocal nonumber")
       (vim.fn.termopen command)
       ;;(vim.fn.feedkeys "G")
       ))

(set util.floating-terminal-window 
     (fn []
       (util.floating-terminal-command "zsh")))

(set util.floating-psql 
     (fn [username database port]
       (util.floating-terminal-command (.. "psql -h 0.0.0.0 -U " username " -d " database " -p " port))
       (set nvim.bo.filetype "sql")
       (set nvim.bo.syntax "sql")))

(set util.floating-repl 
     (fn [c]
       (util.floating-terminal-command c)
       (set nvim.bo.filetype "clojure")
       (set nvim.bo.syntax "clojure") ))

(set util.pane-repl 
     (fn [c]
       (util.pane-terminal-command c)
       (set nvim.bo.filetype "clojure")
       (set nvim.bo.syntax "clojure") ))

(set util.pane-terminal-window 
     (fn []
       (util.pane-terminal-command "zsh")))

(set util.pane-sql 
     (fn [username database port]
       (util.pane-terminal-command (.. "psql -h 0.0.0.0 -U " username " -d " database " -p " port))
       (set nvim.bo.filetype "sql")
       (set nvim.bo.syntax "sql")))

(set util.floating-buf 
     (fn [bufnum]
       (let [ui (. (vim.api.nvim_list_uis) 1)
             margin 50]
         (vim.api.nvim_open_win
           bufnum true {:relative "editor"
                        :border "rounded"
                        :row 1 
                        :col (- (/ (. ui :width) 2) (/ (- (. ui :width) margin) 2))
                        :width (- (. ui :width) margin) :height (- (. ui :height) 10)})
         (vim.cmd ":0"))))

(set util.pane-buf 
     (fn [bufnum]
       (vim.cmd "wincmd n")
       (vim.cmd "wincmd J")
       (vim.cmd "12wincmd_")
       (vim.cmd (.. "buffer " bufnum))))

(set util.current-project 
     (fn []
       (vim.fn.call "FindRootDirectory" [])))

(set util.build-env 
     (fn [env]
       (let [lines (util.split env "\n")
             lines (icollect [_ l (ipairs lines)]
                     (if (not (string.find l "^#"))
                       l))
             vars (util.join lines " ")
             no-exp-vars (util.join (util.split vars "EXPORT ") "")
             no-exp-vars (util.join (util.split no-exp-vars "export ") "")]
         no-exp-vars)))

(set util.read-env 
     (fn [path]
       (if (util.exists? path)
         (let [file (io.open path "r")
               env (util.build-env (file:read "*a"))]
           env)
         "")))

(set util.read-project-env 
     (fn []
       (let [project (util.current-project)
             env (.. project "/.env")]
         (util.read-env env))))

(set util.which-key-deregister 
     (fn [_prefix _lhs]
       ))

(set util.which-key-clear-major 
     (fn []
       (util.which-key-deregister " "
                                  [:ma :mb :mc :md :me :mf :mg :mh :mi :mj :mk :ml :mm :mn :mo :mp
                                   :mq :mr :ms :mt :mu :mv :mx :my :mz])))

(set util.code-block
     (fn [start-s end-s]
       (let [[line1 _] (vim.fn.searchpos start-s "bc")
             [line2 _] (vim.fn.searchpos end-s "c")
             code (vim.fn.getline line1 line2)]
         code)))
util

