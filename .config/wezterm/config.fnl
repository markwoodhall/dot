(local wezterm (require :wezterm))
(local config {})
(set config.color_scheme "Catppuccin Mocha")
(set config.use_fancy_tab_bar true)
(set config.font (wezterm.font "JetBrains Mono"))
(set config.font_size 12.8)
(set config.leader {:key :b :mods :CTRL :timeout_milliseconds 1000 })

(set config.colors 
     {:tab_bar 
      {:inactive_tab_edge "#1e1e2e"
       :background "#1E1E2E" 
       :new_tab
       {:bg_color "#1e1e2e" 
        :fg_color "#1e1e2e"}
       :active_tab 
       {:bg_color "#1e1e2e" 
        :fg_color "#a6e3a1"} 
       :inactive_tab 
       {:bg_color "#1e1e2e" 
        :fg_color "#6c7086"}}})

(set config.window_frame
     {:active_titlebar_bg "#1e1e2e"
      :inactive_titlebar_bg "#1e1e2e"})

(fn new-workspace [window pane line]
  (when line
    (window:perform_action 
      (wezterm.action.SwitchToWorkspace {:name line}) 
      pane)))

(fn rename-tab [window _pane line]
  (when line
    (let [tab (window:active_tab)]
      (tab:set_title line))))

(set config.unix_domains [{:name "dot"} {:name "abv"} {:name "pelly"}])
(set config.default_gui_startup_args ["connect" "dot"])

(set config.keys [{:mods :LEADER :key :H :action (wezterm.action.SplitVertical {:domain :CurrentPaneDomain})}
                  {:mods :LEADER :key :h :action (wezterm.action.SplitHorizontal {:domain :CurrentPaneDomain})}
                  {:mods :LEADER :key "[" :action wezterm.action.ActivateCopyMode}
                  {:mods :LEADER :key :c :action (wezterm.action.SpawnTab :CurrentPaneDomain)}
                  {:mods :LEADER :key :r :action (wezterm.action.PromptInputLine {:description "Enter a tab name" :action (wezterm.action_callback rename-tab)})}
                  {:mods :LEADER :key :1 :action (wezterm.action.ActivateTab 0)}
                  {:mods :LEADER :key :2 :action (wezterm.action.ActivateTab 1)}
                  {:mods :LEADER :key :3 :action (wezterm.action.ActivateTab 2)}
                  {:mods :LEADER :key :4 :action (wezterm.action.ActivateTab 3)}
                  {:mods :LEADER :key :5 :action (wezterm.action.ActivateTab 4)}
                  {:mods :LEADER :key :6 :action (wezterm.action.ActivateTab 5)}
                  {:mods :LEADER :key :7 :action (wezterm.action.ActivateTab 6)}
                  {:mods :LEADER :key :8 :action (wezterm.action.ActivateTab 7)}
                  {:mods :LEADER :key :9 :action (wezterm.action.ActivateTab 8)}
                  {:mods :LEADER :key :t :action (wezterm.action.ShowLauncherArgs {:flags "FUZZY|TABS|WORKSPACES|DOMAINS"})}
                  {:mods :LEADER :key :w :action (wezterm.action.PromptInputLine {:description "Enter a workspace name" :action (wezterm.action_callback new-workspace)})}])

config
