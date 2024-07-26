(local telescope {})
(local util (require :util))

(fn wrapper [title data-fn sink-fn]
  (let [pickers (require "telescope.pickers")
        finders (require "telescope.finders")
        config (require "telescope.config")
        conf (. config :values)
        actions (require "telescope.actions")
        action_state (require "telescope.actions.state")]
    (fn [opts]
      (let [o (or opts {})
            picker (pickers.new
                     o
                     {:prompt_title title
                      :finder (finders.new_table
                                {:results (data-fn)})
                      :sorter (conf.generic_sorter o)
                      :theme "ivy"
                      :attach_mappings (fn [prompt-bufnr map]
                                         (map "i" "<C-j>" actions.move_selection_next)
                                         (map "i" "<C-k>" actions.move_selection_previous)
                                         (actions.select_default:replace
                                           (fn []
                                             (actions.close prompt-bufnr)
                                             (sink-fn (action_state.get_selected_entry))))
                                         true)})]
        (picker:find)))))

(local clj-in-namespace
  (wrapper
    "Switch to Namespace"
    #(vim.fn.call "cljreloaded#all_ns" [])
    (fn [selection]
      (let [ns (. selection 1)
            cmd (.. "ReloadedInNs " ns)]
        (vim.cmd cmd)))))

(fn clj-namespace-publics [ns]
  (wrapper
    "Namespace Publics"
    #(vim.fn.call "cljreloaded#ns_publics" [ns])
    (fn [selection]
      (let [sym (. selection 1)]
        (vim.cmd (.. "ClojureDocs " sym))))))

(local clj-explore-namespace
  (wrapper
    "Explore Namespace"
    #(vim.fn.call "cljreloaded#all_ns" [])
    (fn [selection]
      (let [ns (. selection 1)]
        ((clj-namespace-publics ns))))))

(fn clj-publics [title pattern run]
  (wrapper
    title
    (fn []
      (let [publics (vim.fn.call "cljreloaded#all_publics" [])]
        (icollect [_ v (pairs publics)]
          (when (or (= pattern "")
                    (string.find v pattern))
            v))))
    (fn [selection]
      (let [symbol (. selection 1)]
        (if (= "string" (type run))
          (vim.cmd (.. run  " " symbol))
          (run symbol))))))

(set telescope.scripts
  (wrapper
    "Zsh History"
    #(-> "cat /home/markwoodhall/.zsh_history"
         (vim.fn.system)
         (vim.fn.split "\n"))
    (fn [selection]
      (let [first (. selection 1)
            script-parts (vim.fn.split first ";")
            script (. script-parts 1)]
        (vim.cmd (.. "Start" script))))))

(set telescope.repl
  (wrapper
    "Repl"
    (fn []
      ["AWS_PROFILE=algorithmica-dev AWS_REGION=eu-west-1 lein repl" 
       "lein repl" 
       "npx shadow-cljs watch app"
       "npm run watch"])
    #(util.pane-repl (. $1 1))))

(set telescope.repls
  (wrapper
    "Repls"
    (fn []
      (let [bufs (vim.api.nvim_list_bufs)]
        (icollect [_ b (pairs bufs)]
          (let [bi (vim.fn.getbufinfo b)
                bi-first (. bi 1)
                vars (. bi-first :variables)
                term-title (?. vars "term_title")]
            (when (and term-title
                       (or (> (util.count-matches term-title "lein repl") 0)
                           (> (util.count-matches term-title "shadow") 0)))
              (.. b ":" term-title))))))
    (fn [a] 
      (vim.cmd (.. "buffer " (tonumber (. (util.split (. a 1) ":") 1)))))))

(set telescope.terminals
  (wrapper
    "Terminals"
    (fn []
      (let [bufs (vim.api.nvim_list_bufs)]
        (icollect [_ b (pairs bufs)]
          (let [bi (vim.fn.getbufinfo b)
                bi-first (. bi 1)
                vars (. bi-first :variables)]
            (when (?. vars "term_title")
              (.. b ":" (. vars "term_title")))))))
    (fn [a] 
      (vim.cmd (.. "buffer " (tonumber (. (util.split (. a 1) ":") 1)))))))

(set telescope.projects
  (wrapper
    "Projects"
    (fn []
      (let [bufs (vim.api.nvim_list_bufs)]
        (icollect [_ b (pairs bufs)]
          (let [bi (vim.fn.getbufinfo b)
                bi-first (. bi 1)
                vars (. bi-first :variables)]
            (if (?. vars "rootDir")
              (. vars "rootDir"))))))
    #(vim.cmd (.. "e " (. $1 1)))))

(vim.api.nvim_create_user_command
  "CljDocs"
  (fn [opts]
    ((clj-publics "Clojure Docs" "^clojure" "ClojureDocs") opts))
  {:bang false :desc "Clojure Docs"})

(vim.api.nvim_create_user_command
  "CljApropos"
  (fn [opts]
    ((clj-publics
       "Clojure Apropos"
       ""
       (fn [sym]
         (let [source (-> (vim.fn.call "cljreloaded#source" [sym])
                          (string.sub 2 -2)
                          (string.gsub "\\\"" "\""))]
           (util.floating-window "clojure" source false true)))) opts))
  {:bang false :desc "Clojure Docs"})

(vim.api.nvim_create_user_command
  "CljInNamespace"
  (fn [opts]
    (clj-in-namespace opts))
  {:bang false :desc "Switch to Namespace"})

(vim.api.nvim_create_user_command
  "CljExplore"
  (fn [opts]
    (clj-explore-namespace opts))
  {:bang false :desc "Explore Namespace"})

(vim.api.nvim_create_user_command
  "ZshHistory"
  (fn [opts]
    (telescope.scripts opts))
  {:bang false :desc "Zsh History"})

(vim.api.nvim_create_user_command
  "Repl"
  (fn [opts]
    (telescope.repl opts))
  {:bang false :desc "Repls"})

(vim.api.nvim_create_user_command
  "Projects"
  (fn [opts]
    (telescope.projects opts))
  {:bang false :desc "Projects"})

(vim.api.nvim_create_user_command
  "Terminals"
  (fn [opts]
    (telescope.terminals opts))
  {:bang false :desc "Terminals"})

(vim.api.nvim_create_user_command
  "Repls"
  (fn [opts]
    (telescope.repls opts))
  {:bang false :desc "Repls"})

(let [ts (require :telescope)
      actions (require "telescope.actions")
      action_state (require "telescope.actions.state")]
  (ts.setup {:defaults 
             {:layout_strategy :bottom_pane
              :border false
              :sorting_strategy :ascending
              :layout_config {:height 0.3}
              :mappings {:i {"<C-j>" actions.move_selection_next
                             "<C-x>" (fn [b] 
                                       (vim.api.nvim_buf_delete
                                         (or (?. (action_state.get_selected_entry b) :bufnr)
                                             (tonumber (. (util.split (?. (action_state.get_selected_entry b) 1) ":") 1)))
                                         {:force true})
                                       (actions.close b)
                                       (vim.cmd ":Telescope buffers"))
                             "<C-f>" (fn [b] 
                                       (actions.close b)
                                       (util.floating-buf  
                                         (or (?. (action_state.get_selected_entry b) :bufnr)
                                             (tonumber (. (util.split (?. (action_state.get_selected_entry b) 1) ":") 1)))))
                             "<C-p>" (fn [b] 
                                       (actions.close b)
                                       (util.pane-buf  
                                         (or (?. (action_state.get_selected_entry b) :bufnr)
                                             (tonumber (. (util.split (?. (action_state.get_selected_entry b) 1) ":") 1)))))
                             "<C-k>" actions.move_selection_previous}}}}))

telescope
