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

(set telescope.clojure 
     (fn []
       (let [clj-in-namespace (wrapper
                                "Switch to Namespace"
                                #(vim.fn.call "cljreloaded#all_ns" [])
                                (fn [selection]
                                  (let [ns (. selection 1)
                                        cmd (.. "ReloadedInNs " ns)]
                                    (vim.cmd cmd))))
             clj-namespace-publics (fn [ns] (wrapper
                                              "Namespace Publics"
                                              #(vim.fn.call "cljreloaded#ns_publics" [ns])
                                              (fn [selection]
                                                (let [sym (. selection 1)]
                                                  (vim.cmd (.. "ClojureDocs " sym))))))
             clj-publics (fn [title pattern run]
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
                                   (run symbol))))))]
         (vim.api.nvim_buf_create_user_command
           0
           "CljDocs"
           (fn [opts]
             ((clj-publics "Clojure Docs" "^clojure" "ClojureDocs") opts))
           {:bang false :desc "Clojure Docs"})

         (vim.api.nvim_buf_create_user_command
           0
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

         (vim.api.nvim_buf_create_user_command
           0
           "CljInNamespace"
           (fn [opts]
             (clj-in-namespace opts))
           {:bang false :desc "Switch to Namespace"})

         (vim.api.nvim_buf_create_user_command
           0
           "CljExplore"
           (wrapper
             "Explore Namespace"
             #(vim.fn.call "cljreloaded#all_ns" [])
             (fn [selection]
               (let [ns (. selection 1)]
                 ((clj-namespace-publics ns)))))
           {:bang false :desc "Explore Namespace"})

         (vim.api.nvim_buf_create_user_command
           0
           "Repl"
           (wrapper
             "Repl"
             (fn []
               ["lein repl" 
                "npx shadow-cljs watch app"
                "fennel"
                "npm run watch"])
             #(util.pane-repl (. $1 1)))
           {:bang false :desc "Repls"}))))

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
