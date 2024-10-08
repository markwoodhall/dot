(pcall require :luarocks.loader)
(require :awful.autofocus)
(require :awful.hotkeys_popup.keys)

(local gears (require :gears))
(local awful (require :awful))
(local dpi (. (require :beautiful.xresources) :apply_dpi))
(local beautiful (require :beautiful))
(local naughty (require :naughty))

;; Set up error handling
(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :text awesome.startup_errors
                   :title "Oops, there were errors during startup!"}))

(do
  (var in-error false)
  (awesome.connect_signal "debug::error"
                          (fn [err]
                            (when in-error (lua "return "))
                            (set in-error true)
                            (naughty.notify {:preset naughty.config.presets.critical
                                             :text (tostring err)
                                             :title "Oops, an error happened!"})
                            (set in-error false))))

(beautiful.init (.. (gears.filesystem.get_themes_dir) :default/theme.lua))

;; Set terminal, editor and modkey
(global terminal :kitty)
(global editor (or (os.getenv :EDITOR) :nvim))
(global editor-cmd (.. terminal " -e " editor))
(global modkey :Mod1)

;; Tiling preferences
(set awful.layout.layouts
     [awful.layout.suit.tile.left
      awful.layout.suit.tile
      awful.layout.suit.floating])

;; Wallpaper
(fn set-wallpaper [s]
  (when beautiful.wallpaper
    (var wallpaper "/home/markwoodhall/src/mark/dot/wallpaper.png")
    (when (= (type wallpaper) :function) (set wallpaper (wallpaper s)))
    (gears.wallpaper.maximized wallpaper s true)))

(screen.connect_signal "property::geometry" set-wallpaper)
(awful.screen.connect_for_each_screen (fn [s]
                                        (set-wallpaper s)
                                        (awful.tag [:1 :2 :3 :4 :5 :6 :7 :8 :9]
                                                   s (. awful.layout.layouts 1))))

;; Global key bindings
(global globalkeys
  (gears.table.join 
    (awful.key [modkey] :Escape awful.tag.history.restore
               {:description "go back" :group :tag})
    (awful.key [modkey] :j
               (fn [] (awful.client.focus.byidx 1))
               {:description "focus next by index"
                :group :client})
    (awful.key [modkey] :k
               (fn [] (awful.client.focus.byidx (- 1)))
               {:description "focus previous by index"
                :group :client})
    (awful.key [modkey] :l
               (fn [] (awful.tag.incmwfact 0.05))
               {:description "increase master width factor"
                :group :layout})
    (awful.key [modkey] :h
               (fn [] (awful.tag.incmwfact -0.05))
               {:description "decrease master width factor"
                :group :layout})
    (awful.key [modkey :Shift] :j
               (fn [] (awful.client.swap.byidx 1))
               {:description "swap with next client by index"
                :group :client})
    (awful.key [modkey :Shift] :k
               (fn [] (awful.client.swap.byidx (- 1)))
               {:description "swap with previous client by index"
                :group :client})
    (awful.key [modkey] :Return
               (fn [] (awful.spawn terminal))
               {:description "open a terminal"
                :group :launcher})
    (awful.key [modkey :Shift] :r awesome.restart
               {:description "reload awesome"
                :group :awesome})
    (awful.key [modkey :Shift] :e awesome.quit
               {:description "quit awesome"
                :group :awesome})
    (awful.key [modkey] :space
               (fn [] (awful.layout.inc 1))
               {:description "select next"
                :group :layout})
    (awful.key [modkey :Shift] :space
               (fn [] (awful.layout.inc (- 1)))
               {:description "select previous"
                :group :layout})
    (awful.key [modkey] :d
               (fn []
                 (awful.spawn "rofi -show run"))
               {:description "run rofi"
                :group :launcher})))

;; Application state based keys, e.g. toggle fullscreen, floating, kill
(global clientkeys
  (gears.table.join 
    (awful.key [modkey] :f
               (fn [c]
                 (set c.fullscreen (not c.fullscreen))
                 (c:raise))
               {:description "toggle fullscreen"
                :group :client})
    (awful.key [modkey :Shift] :q (fn [c] (c:kill))
               {:description :close :group :client})
    (awful.key [modkey :Control] :space
               awful.client.floating.toggle
               {:description "toggle floating"
                :group :client})
    (awful.key [modkey] :t
               (fn [c] (set c.ontop (not c.ontop)))
               {:description "toggle keep on top"
                :group :client})))

;; Bind number keys to tags
(for [i 1 9]
  (global globalkeys
    (gears.table.join 
      globalkeys
      (awful.key [modkey] (.. "#" (+ i 9))
                 (fn []
                   (let [screen (awful.screen.focused)
                         tag (. screen.tags i)]
                     (when tag (tag:view_only))))
                 {:description (.. "view tag #" i)
                  :group :tag})
      (awful.key [modkey :Control] (.. "#" (+ i 9))
                 (fn []
                   (let [screen (awful.screen.focused)
                         tag (. screen.tags i)]
                     (when tag (awful.tag.viewtoggle tag))))
                 {:description (.. "toggle tag #" i)
                  :group :tag})
      (awful.key [modkey :Shift] (.. "#" (+ i 9))
                 (fn []
                   (when client.focus
                     (local tag
                       (. client.focus.screen.tags i))
                     (when tag
                       (client.focus:move_to_tag tag))))
                 {:description (.. "move focused client to tag #"
                                   i)
                  :group :tag})
      (awful.key [modkey :Control :Shift]
                 (.. "#" (+ i 9))
                 (fn []
                   (when client.focus
                     (local tag
                       (. client.focus.screen.tags i))
                     (when tag
                       (client.focus:toggle_tag tag))))
                 {:description (.. "toggle focused client on tag #"
                                   i)
                  :group :tag}))))
(root.keys globalkeys)

;; Send programs to certain tags automatically
(set awful.rules.rules
     [{:rule {:class "Kitty"}
       :properties {:tag :1}}
      {:rule_any {:type ["dialog"]}
       :properties {:floating true}}
      {:rule {:class :Slack}
       :properties {:tag :4}}
      {:rule {:class "vivaldi-stable"}
       :properties {:tag :3}}
      {:properties {:border_color "#11111b"
                    :border_width 1
                    :focus awful.client.focus.filter
                    :keys clientkeys
                    :placement (+ awful.placement.no_overlap
                                  awful.placement.no_offscreen)
                    :raise true
                    :screen awful.screen.preferred}
       :rule {}}
      {:properties {:titlebars_enabled false}
       :rule_any {:type [:normal :dialog]}}])

(client.connect_signal :manage
                       (fn [c]
                         (when (and (and awesome.startup
                                         (not c.size_hints.user_position))
                                    (not c.size_hints.program_position))
                           (awful.placement.no_offscreen c))))

(client.connect_signal "mouse::enter"
                       (fn [c]
                         (c:emit_signal "request::activate" :mouse_enter
                                        {:raise false})))
(set beautiful.font "System-ui 12")

;; Gaps
(set beautiful.useless_gap 0)

;; Notifications settings
(set naughty.config.defaults.ontop true)
(set naughty.config.defaults.icon_size (dpi 360))
(set naughty.config.defaults.timeout 10)
(set naughty.config.defaults.hover_timeout 300)
(set naughty.config.defaults.title "System Notification Title")
(set naughty.config.defaults.margin (dpi 16))
(set naughty.config.defaults.border_width 0)
(set naughty.config.defaults.width 450)
(set naughty.config.defaults.max_width 450)
(set naughty.config.defaults.max_height 130)
(set naughty.config.defaults.position "top_middle")
(set naughty.config.defaults.font "System-ui 11")
(set naughty.config.defaults.bg "#1e1e2e")
(set naughty.config.defaults.fg "#CDD6f4")

(set naughty.config.padding (dpi 38))
(set naughty.config.spacing (dpi 8))

;; Auto start applications
;; Change caps lock to control
(awful.spawn "setxkbmap -option caps:ctrl_modifier")

(awful.spawn "picom")

(local restart?
      (fn []
        (var restart_detected false)
        (when (not restart_detected)
          (awesome.register_xproperty "awesome_restart_check" "boolean")
          (set restart_detected (awesome.get_xproperty "awesome_restart_check"))
          (awesome.set_xproperty "awesome_restart_check" true))
        restart_detected))

(when (not (restart?))
  (do
    (awful.spawn "/opt/lebar/lebardock")
    (awful.spawn "kitty")
    (awful.spawn "slack")
    (awful.spawn "insync start")
    (awful.spawn "xscreensaver")
    (awful.spawn "vivaldi")))
