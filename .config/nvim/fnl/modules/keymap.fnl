(local util (require :util))
(local nvim (require "nvim"))
(local ts (require "modules.telescope"))
(local notes (require "modules.notes"))

(let [wk (require :which-key)]
  (wk.setup {:triggers [" "]})
  (wk.add 
    [{1 " f" :group "file"}
     {1 " b" :group "buffer"}
     {1 " g" :group "git"}
     {1 " gP" :group "push"}
     {1 " l" :group "lsp"}
     {1 " p" :group "project"}
     {1 " lg" :group "goto"}
     {1 " ld" :group "diagnostics"}
     {1 " n" :group "notes"}
     {1 " t" :group "terminal"}
     {1 " tr" :group "run"}
     {1 " tp" :group "psql"}
     {1 " w" :group "window"}]))

;; buffers
(util.nnoremap "bh" "nohl" "no-highlight-search")
(util.nnoremap "bl" "Telescope buffers" "telescope-list-buffers")
(util.nnoremap "bn" "bn" "goto-next-buffer")
(util.nnoremap "bp" "bp" "goto-previous-buffer")
(util.nnoremap "bf" "call SearchWordWithAg()" "ag-search-word-under-cursor")
(util.nnoremap "bc" "set list!" "show-non-displayable-characters")
(util.nnoremap "bx" "close" "close-buffer")
(util.nnoremap "bX" "bd!" "delete-buffer")

;; files
(util.nnoremap "ff" "Telescope find_files hidden=true search_dirs={\"~/\"}" "telescope-find-files-home")
(util.nnoremap "fr" "lua require'telescope.builtin'.oldfiles{}" "telescope-recent-files")
(util.nnoremap "fg" "Telescope live_grep hidden=true" "telescope-live-grep")
(util.nnoremap "fv" "vsplit $MYVIMRC" "split-open-vimrc")

;; git
(util.nnoremap "gf" "Telescope git_files hidden=true" "Find git files")
(util.nnoremap "gc" "Telescope git_commits" "Git commits")
(util.nnoremap "gb" "Telescope git_branches" "Git branches")
(util.nnoremap "gs" "G" "Git status")
(util.nnoremap "gp" "Git pull --rebase=true" "Git pull --rebase")
(util.nnoremap "gPp" "Git push" "Git push")
(util.nnoremap "gPP" "Git push --force-with-lease" "Git push --force-with-lease")

;; lsp
(util.nnoremap "lda" "lua vim.lsp.buf.code_action()" "telescope-lsp-diagnostics-code-actions")
(util.nnoremap "ldd" "Telescope diagnostics bufnr=0" "telescope-lsp-diagnostics-buffer")
(util.nnoremap "ldD" "Telescope diagnostics" "telescope-lsp-diagnostics-project")
(util.nnoremap "ldr" "Telescope lsp_references" "telescope-lsp-references")
(util.nnoremap "ldf" "ALEFix" "Run ALE fix")
(util.nnoremap "lf" "lua vim.lsp.buf.format()" "lsp-format-buffer")
(util.nnoremap "lgd" "Telescope lsp_definitions" "telescope-lsp-definitions")

(nvim.set_keymap "n" "K" ":lua vim.lsp.buf.hover()<CR>" {:noremap true :silent true})

;; projects
(util.nnoremap "pf" "Telescope find_files" "telescope-find-files-in-project")

;; windows
(vim.keymap.set "n" " ws" "<c-w>v<c-w>w" {:desc "Split window vertically"})
(vim.keymap.set "n" " wS" "<c-w>s" {:desc "Split window horizontally"})
(vim.keymap.set "n" " wh" "<c-w>h" {:desc "Move to right window"})
(vim.keymap.set "n" " wj" "<c-w>j" {:desc "Move to below window"})
(vim.keymap.set "n" " wk" "<c-w>k" {:desc "Move to above window"})
(vim.keymap.set "n" " wl" "<c-w>l" {:desc "Move to left window"})
(vim.keymap.set "n" " wm" "<c-w>|<c-w>_" {:desc "Maximize window"})
(vim.keymap.set "n" " w=" "<c-w>=" {:desc "Balance windows"})

;; notes
(util.nnoremap "ng" (.. "Telescope live_grep hidden=true search_dirs={\"" (notes.get-notes-path) "\"}") "telescope-grep-notes")
(util.nnoremap "nf" (.. "Telescope find_files hidden=true search_dirs={\"" (notes.get-notes-path) "\"}") "telescope-find-notes")
(util.nnoremap "nn" "NewNote" "create-new-note")

;; terminal
(util.nnoremap "tt" "Start" "start-new-tmux-window")
(vim.keymap.set "n" " tn" util.pane-terminal-window {:desc "Start a new terminl"})
(vim.keymap.set "n" " tf" util.pane-terminal-window {:desc "Start a new terminl"})
(vim.keymap.set "n" " trd" util.rerun-last-drawer-command {:desc "Rerun the last drawer command"})
(vim.keymap.set "n" " trp" util.rerun-last-pane-command {:desc "Rerun the last pane command"})
(vim.keymap.set "n" " tpl" (fn [] (util.pane-psql "localhost" "database" 5432)) {:desc "psql (localhost)"})

(vim.keymap.set "n" "gF" ":aboveleft wincmd F<CR>")
(vim.keymap.set "n" "<esc><esc>" ":close<CR>")

(vim.keymap.set "n" "-" "<CMD>Oil<CR>" {:desc "Open parent directory" })
