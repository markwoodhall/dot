(local util (require :util))
(local nvim (require "nvim"))
;;(local notes (require "modules.notes"))

(let [wk (require :which-key)]
  (wk.setup {:triggers [" "]})
  (wk.add 
    [{1 " f" :group "find"}
     {1 " b" :group "buffer"}
     {1 " g" :group "git"}
     {1 " gP" :group "push"}
     {1 " l" :group "lsp"}
     {1 " lg" :group "goto"}
     {1 " ld" :group "diagnostics"}
     {1 " n" :group "notes"}
     {1 " t" :group "terminal"}
     {1 " w" :group "window"}]))

;; buffers
(util.nnoremap "bl" "Buffers" "list-buffers")
(util.nnoremap "bh" "nohl" "no-highlight-search")
(util.nnoremap "bn" "bn" "goto-next-buffer")
(util.nnoremap "bp" "bp" "goto-previous-buffer")
(util.nnoremap "bf" "grep " "grep-word-under-cursor")
(util.nnoremap "bc" "set list!" "show-non-displayable-characters")
(util.nnoremap "bx" "close" "close-buffer")
(util.nnoremap "bX" "bd!" "delete-buffer")

;; find
(util.nnoremap-wait "fg" "Rg" "live-grep")
(util.nnoremap "fw" "grep <cword>" "find-word-under-cursor")
(util.nnoremap "fr" "call setloclist(0, g:recent_files) <bar> lopen" "find-recent-files")

;; git
(util.nnoremap "gd" "Gvdiffsplit" "git-diff")
(util.nnoremap "gs" "G" "git-status")
(util.nnoremap "gp" "Git pull --rebase=true" "git-pull-rebase")
(util.nnoremap "gPp" "Git push" "git-push")
(util.nnoremap "gPP" "Git push --force-with-lease" "git-push-force-with-lease")

;; lsp
(util.nnoremap "lda" "lua vim.lsp.buf.code_action()" "lsp-diagnostics-code-actions")
(util.nnoremap "lf" "lua vim.lsp.buf.format()" "lsp-format-buffer")
(util.nnoremap "lgd" "lua vim.lsp.buf.definition()" "lsp-definitions")

(nvim.set_keymap "n" "K" ":lua vim.lsp.buf.hover()<CR>" {:noremap true :silent true})

;; windows
(vim.keymap.set "n" " ws" "<c-w>v<c-w>w" {:desc "split-window-vertically"})
(vim.keymap.set "n" " wS" "<c-w>s" {:desc "split-window-horizontally"})
(vim.keymap.set "n" " wh" "<c-w>h" {:desc "move-to-right-window"})
(vim.keymap.set "n" " wj" "<c-w>j" {:desc "Move-to-below-window"})
(vim.keymap.set "n" " wk" "<c-w>k" {:desc "Move-to-above-window"})
(vim.keymap.set "n" " wl" "<c-w>l" {:desc "Move-to-left-window"})
(vim.keymap.set "n" " wm" "<c-w>|<c-w>_" {:desc "maximize-window"})
(vim.keymap.set "n" " w=" "<c-w>=" {:desc "balance-windows"})

;; notes
(util.nnoremap "nn" "NewNote" "create-new-note")

;; terminal
(util.nnoremap "tt" "Start" "start-new-tmux-window")
(vim.keymap.set "n" " tn" util.pane-terminal-window {:desc "start-new-terminal"})

(vim.keymap.set "n" "gF" ":aboveleft wincmd F<CR>")
(vim.keymap.set "n" "<esc><esc>" ":close<CR>")
(vim.keymap.set "n" "-" "<CMD>Oil<CR>" {:desc "browse-parent-directory" })
