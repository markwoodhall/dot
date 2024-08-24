(local lualine (require :lualine))

(local colors {:bg "#1E1E2E"
               :blue "#74c7ec"
               :cyan "#94e2d5"
               :darkblue "#89b4fa"
               :fg "#CDD6F4"
               :grey "#494D64 "
               :green "#a6e3a1"
               :magenta "#ee99a0"
               :orange "#fab387"
               :red "#f38ba8"
               :violet "#c6a0f6"
               :yellow "#F9E2AF"})

(local conditions
  {:buffer_not_empty (fn []
                       (not= (vim.fn.empty (vim.fn.expand "%:t")) 1))
   :check_git_workspace (fn []
                          (local filepath (vim.fn.expand "%:p:h"))
                          (local gitdir
                            (vim.fn.finddir :.git (.. filepath ";")))
                          (and (and gitdir (> (length gitdir) 0))
                               (< (length gitdir) (length filepath))))
   :hide_in_width (fn [] (> (vim.fn.winwidth 0) 80))})

(local config 
  {:inactive_sections {:lualine_a {}
                       :lualine_b {}
                       :lualine_c {}
                       :lualine_x {}
                       :lualine_y {}
                       :lualine_z {}}
   :options {:component_separators ""
             :globalStatus true
             :section_separators ""
             :theme :catppuccin
             }
   :sections {:lualine_a {}
              :lualine_b {}
              :lualine_c {}
              :lualine_x {}
              :lualine_y {}
              :lualine_z {}}})

(fn active-lsp []
  (var msg "No Active Lsp")
  (let [buf-ft (vim.api.nvim_buf_get_option 0 :filetype)
        clients (vim.lsp.get_active_clients)]
    (if (= (next clients) nil)
      msg
      (do 
        (each [_ client (ipairs clients)]
          (local filetypes client.config.filetypes)
          (when (and filetypes
                     (not= (vim.fn.index filetypes buf-ft) (- 1)))
            (let [name client.name]
              (set msg name))))
        msg))))

(fn ins-left [component] (table.insert config.sections.lualine_c component))
(fn ins-right [component] (table.insert config.sections.lualine_x component))

(ins-left {1 (fn [] "▊")
           :color {:fg colors.blue}
           :padding {:left 0 :right 1}})

(ins-left {1 (fn []
               ((. (require :nvim-web-devicons) :get_icon_by_filetype) (vim.api.nvim_buf_get_option 0 :filetype) {}))
           :color (fn []
                    (local mode-color
                      {"\019" colors.orange
                       "\022" colors.blue
                       :! colors.red
                       :R colors.violet
                       :Rv colors.violet
                       :S colors.orange
                       :V colors.blue
                       :c colors.magenta
                       :ce colors.red
                       :cv colors.red
                       :i colors.green
                       :ic colors.yellow
                       :n colors.red
                       :no colors.red
                       :r colors.cyan
                       :r? colors.cyan
                       :rm colors.cyan
                       :s colors.orange
                       :t colors.red
                       :v colors.blue})
                    {:fg (. mode-color (vim.fn.mode))})
           :padding {:right 1}})
(ins-left {1 :filesize :cond conditions.buffer_not_empty})
(ins-left {1 :filename
           :color {:fg colors.magenta :gui :bold}
           :cond conditions.buffer_not_empty})
(ins-left [:location])
(ins-left {1 :progress :color {:fg colors.fg :gui :bold}})
(ins-left {1 :diagnostics
           :diagnostics_color {:color_error {:fg colors.red}
                               :color_info {:fg colors.cyan}
                               :color_warn {:fg colors.yellow}}
           :sources [:nvim_diagnostic]
           :symbols {:error "  " :info "  " :warn "  "}})
(ins-left [(fn [] "%=")])
(ins-left {1 active-lsp
           :color (fn [] (if (= (active-lsp) "No Active Lsp") {:fg colors.grey :gui :bold} {:fg colors.green :gui :bold}))
           :icon " LSP:"})
(ins-left {1 (fn [] (vim.fn.call :FireplaceConnected {}))
           :color (fn [] 
                    (let [repl-state (vim.fn.call :FireplaceConnected {})]
                      (if (or (= repl-state "unknown")
                              (= repl-state 0)) 
                        {:fg colors.grey :gui :bold} 
                        {:fg colors.green :gui :bold})))
           :cond (fn []
                   (and true (= (vim.api.nvim_buf_get_option 0 :filetype)
                                :clojure)))
           :icon (.. ((. (require :nvim-web-devicons) :get_icon_by_filetype) :clojure
                      {})
                     " nREPL:")})
(ins-right {1 "o:encoding"
            :color {:fg colors.green :gui :bold}
            :cond conditions.hide_in_width
            :fmt string.upper})
(ins-right {1 :fileformat
            :color {:fg colors.green :gui :bold}
            :fmt string.upper
            :icons_enabled false})
(ins-right {1 :branch :color {:fg colors.violet :gui :bold} :icon ""})
(ins-right {1 :diff
            :cond conditions.hide_in_width
            :diff_color {:added {:fg colors.green}
                         :modified {:fg colors.orange}
                         :removed {:fg colors.red}}
            :symbols {:added "+ " :modified "~ " :removed "- "}})
(ins-right {1 (fn [] "▊") :color {:fg colors.blue} :padding {:left 1}})
(lualine.setup config)	
