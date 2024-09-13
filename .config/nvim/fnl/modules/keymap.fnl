(local nvim (require "nvim"))

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
(vim.keymap.set "n" " ba" ":e #<CR>" {:desc "toggle-buffers"})
(vim.keymap.set "n" " bl" ":Buffers<CR>" {:desc "list-buffers"})
(vim.keymap.set "n" " bh" ":nohl<CR>" {:desc "no-highlight-search"})
(vim.keymap.set "n" " bn" ":bn<CR>" {:desc "goto-next-buffer"})
(vim.keymap.set "n" " bp" ":bp<CR>" {:desc "goto-previous-buffer"})
(vim.keymap.set "n" " bx" ":close<CR>" {:desc "close-buffer"})
(vim.keymap.set "n" " bX" ":bd!<CR>" {:desc "delete-buffer"})

;; find
(vim.keymap.set "n" " fw" ":grep <cword><CR>" {:desc "find-word"})
(vim.keymap.set "n" " fr" ":call setloclist(0, g:recent_files) <bar> lopen<CR>" {:desc "find-recent"})

;; git
(vim.keymap.set "n" " gd" ":Gvdiffsplit<CR>" {:desc "git-diff"})
(vim.keymap.set "n" " gs" ":G<CR>" {:desc "git-status"})

;; lsp
(vim.keymap.set "n" " ldD" ":lua vim.diagnostic.setqflist()<CR>" {:desc "project-diagnostics"})
(vim.keymap.set "n" " ldd" ":lua vim.diagnostic.setloclist()<CR>" {:desc "buffer-diagnostics"})
(vim.keymap.set "n" " lda" ":lua vim.lsp.buf.code_action()<CR>" {:desc "code-actions"})
(vim.keymap.set "n" " lf" ":lua vim.lsp.buf.format()<CR>" {:desc "format-buffer"})
(vim.keymap.set "n" " lgd" ":lua vim.lsp.buf.definition()<CR>" {:desc "go-to-definition"})

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

(fn module-cmd [module cmd]
  (let [_ (require module)]
    (vim.fn.feedkeys (.. ":" cmd))))


;; notes
(vim.keymap.set "n" " nn" (partial module-cmd :modules.notes "NewNote") {:desc "create-new-note"})

;; terminal
(vim.keymap.set "n" " tn" (fn [] 
                            (let [util (require :util)] 
                              (util.pane-terminal-window))) {:desc "start-new-terminal"})

(vim.keymap.set "n" "gF" ":aboveleft wincmd F<CR>")
(vim.keymap.set "n" "<esc><esc>" ":close<CR>")
