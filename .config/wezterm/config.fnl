(local wezterm (require :wezterm))
(local config {})
(set config.color_scheme "Catppuccin Mocha")
(set config.use_fancy_tab_bar true)
(set config.font (wezterm.font "JetBrains Mono"))
(set config.font_size 10.5)
(set config.leader {:key :b :mods :CTRL :timeout_milliseconds 1000 })

(set config.show_close_tab_button_in_tabs false)
(set config.show_new_tab_button_in_tab_bar false)

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
       {:bg_color "#181825" 
        :fg_color "#45475a"}
       :inactive_tab_hover 
       {:bg_color "#a6e3a1" 
        :fg_color "#1e1e2e"}}})

(set config.window_padding {:left 5 :right 0 :top 0 :bottom 0})

(set config.unix_domains 
     [{:name "unix" 
       :socket_path "/home/markwoodhall/.local/wez.socket" 
       :local_echo_threshold_ms 5000 }])
(set config.default_gui_startup_args [ "connect" "unix" ])

(set config.window_frame
     {:active_titlebar_bg "#181825"
      :inactive_titlebar_bg "#181825"})

(fn new-workspace [window pane line]
  (when line
    (window:perform_action 
      (wezterm.action.SwitchToWorkspace {:name line}) 
      pane)))

(fn rename-tab [window _pane line]
  (when line
    (let [tab (window:active_tab)]
      (tab:set_title line))))

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
                  {:mods :LEADER :key :x :action (wezterm.action.CloseCurrentTab {:confirm false})}
                  {:mods :LEADER :key :t :action (wezterm.action.ShowLauncherArgs {:flags "FUZZY|TABS|WORKSPACES|DOMAINS"})}
                  {:mods :LEADER :key :w :action (wezterm.action.PromptInputLine {:description "Enter a workspace name" :action (wezterm.action_callback new-workspace)})}])

config
