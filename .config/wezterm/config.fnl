(local wezterm (require :wezterm))
(local config {})
(set config.color_scheme "Catppuccin Mocha")
(set config.use_fancy_tab_bar false)
(set config.font (wezterm.font "JetBrains Mono"))
(set config.font_size 12.8)
(set config.leader {:key :b :mods :CTRL :timeout_milliseconds 1000 })

(set config.colors {:tab_bar {:background "#1E1E2E" :active_tab {:bg_color "#a6e3a1" :fg_color "#6c7086"} :inactive_tab {:bg_color "#1e1e2e" :fg_color "#6c7086"}}})

(set config.keys [{:mods :LEADER :key :H :action (wezterm.action.SplitVertical {:domain :CurrentPaneDomain})}
                  {:mods :LEADER :key :h :action (wezterm.action.SplitHorizontal {:domain :CurrentPaneDomain})}
                  {:mods :LEADER :key "[" :action wezterm.action.ActivateCopyMode}
                  {:mods :LEADER :key :c :action (wezterm.action.SpawnTab :CurrentPaneDomain)}
                  {:mods :LEADER :key :1 :action (wezterm.action.ActivateTab 0)}
                  {:mods :LEADER :key :2 :action (wezterm.action.ActivateTab 1)}
                  {:mods :LEADER :key :3 :action (wezterm.action.ActivateTab 2)}
                  {:mods :LEADER :key :4 :action (wezterm.action.ActivateTab 3)}
                  {:mods :LEADER :key :5 :action (wezterm.action.ActivateTab 4)}
                  {:mods :LEADER :key :6 :action (wezterm.action.ActivateTab 5)}
                  {:mods :LEADER :key :7 :action (wezterm.action.ActivateTab 6)}
                  {:mods :LEADER :key :8 :action (wezterm.action.ActivateTab 7)}])

config
