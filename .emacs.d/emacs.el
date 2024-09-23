(setq vc-follow-symlinks t)

(require 'package)
(add-to-list 'package-archives
       '("melpa" . "https://melpa.org/packages/"))
(when (not package-archive-contents)
  (package-refresh-contents))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(setq use-package-always-ensure t)

;; Setting garbage collection threshold
(setq gc-cons-threshold 5002653184
      gc-cons-percentage 0.6)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive (setq comp-async-report-warnings-errors nil)

;; Silence compiler warnings as they can be pretty disruptive
(if (boundp 'comp-deferred-compilation)
    (setq comp-deferred-compilation nil)
    (setq native-comp-jit-compilation nil))
;; In noninteractive sessions, prioritize non-byte-compiled source files to
;; prevent the use of stale byte-code. Otherwise, it saves us a little IO time
;; to skip the mtime checks on every *.elc file.
(setq load-prefer-newer noninteractive)

(setq history-length 50)
(savehist-mode 1)

(use-package evil
  :ensure t
  :init      ;; tweak evil's configuration before loading it
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-search-module 'evil-search)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  :custom (evil-collection-setup-minibuffer t)
  :init (evil-collection-init))

(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package undo-tree
  :ensure t
  :after evil
  :diminish
  :config
  (evil-set-undo-system 'undo-tree)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  (global-undo-tree-mode 1))

(global-set-key (kbd "<escape>") 'keyboard-quit)

(use-package general
  :ensure t
  :config
  (general-evil-setup t))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode nil)
(setq frame-resize-pixelwise t)

(setq-default display-line-numbers-type 'relative)

(add-hook 'prog-mode-hook (lambda() (display-line-numbers-mode 1)))
(add-hook 'text-mode-hook (lambda() (display-line-numbers-mode 1)))

(global-visual-line-mode -1)
(set-default 'truncate-lines t)
(auto-fill-mode -1)

(use-package doom-modeline
   :init
   (doom-modeline-mode 1))

(use-package doom-themes)

(load-theme 'doom-tokyo-night)

(setq switch-to-buffer-obey-display-actions t)

(nvmap :prefix "SPC" :keymaps 'override
   "b"     '(:which-key "buffers")
   "b x"   '((lambda () (interactive) (kill-this-buffer) (evil-window-delete)) :which-key "Kill buffer")
   "b l"   '(counsel-switch-buffer :which-key "List buffers")
   "b n"   '(next-buffer :which-key "Next buffer")
   "b n"   '(rename-buffer :which-key "Rename buffer")
   "b p"   '(previous-buffer :which-key "Previous buffer"))

(setq-default indent-tabs-mode nil)
(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))
(add-hook 'prog-mode-hook #'ws-butler-mode)

(defun mw/named-vterm (name)
  "Start a vterm and renames the buffer NAME."
  (interactive "sTerminal name:")
  (vterm)
  (rename-buffer (concat "vterm-" name)))

(nvmap :prefix "SPC" :keymaps 'override
    "t"     '(:which-key "terminal")
    "t f"   '(mw/named-vterm :which-key "New Terminal")
    "t t"   '((lambda () (interactive) (projectile-run-vterm)) :which-key "New Terminal")
    "t s"   '((lambda () (interactive) (projectile-run-shell)) :which-key "New Shell"))

(delete-selection-mode t)

(nvmap :keymaps '(emacs-lisp-mode-map org-mode-map) :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")
  "m e b" '(eval-buffer :which-key "Eval buffer")
  "m e e" '(eval-defun-at-point :which-key "Eval root expressions")
  "m e E" '(eval-sexp-at-point :which-key "Eval expressions"))

(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "f"     '(:which-key "files")
       "f f"   '(counsel-find-file :which-key "Find file")
       "f g"   '(counsel-rg :which-key "Grep files")
       "f r"   '(counsel-recentf :which-key "Recent files")
       "f s"   '(save-buffer :which-key "Save file")
       "f u"   '(sudo-edit-find-file :which-key "Sudo find file")
       "f C"   '(copy-file :which-key "Copy file")
       "f D"   '(delete-file :which-key "Delete file")
       "f R"   '(rename-file :which-key "Rename file")
       "f S"   '(write-file :which-key "Save file as...")
       "f U"   '(sudo-edit :which-key "Sudo edit file"))

(use-package sudo-edit
  :commands (sudo-edit sudo-edit-find-file sudo-edit)) ;; Utilities for opening files with sudo

(set-face-attribute 'default nil
  :font "JetBrains Mono"
  :height 95
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "JetBrains Mono"
  :height 95
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono"
  :height 95
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; changes certain keywords to symbols, such as lamda!
(setq global-prettify-symbols-mode t)

(nvmap :keymaps 'override :prefix "SPC"
       "SPC"   '(counsel-M-x :which-key "All commands (M-x)")
       "h"     '(:which-key "help")
       "h r"   '(:which-key "reload")
       "h r e" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :which-key "Reload emacs config"))

(use-package ivy
  :defer 0.1
  :diminish
  :bind
  (("C-s" . swiper)
   :map evil-insert-state-map
   ("C-k" . ivy-previous-line)
   ("C-j" . ivy-next-line)
   :map ivy-minibuffer-map
   ("TAB" . ivy-alt-done)
   ("C-l" . ivy-alt-done)
   ("C-j" . ivy-next-line)
   ("C-k" . ivy-previous-line)
   :map ivy-switch-buffer-map
   ("C-k" . ivy-previous-line)
   ("C-j" . ivy-next-line)
   ("C-l" . ivy-done)
   ("C-d" . ivy-switch-buffer-kill)
   :map ivy-reverse-i-search-map
   ("C-k" . ivy-previous-line)
   ("C-j" . ivy-next-line)
   ("C-d" . ivy-reverse-i-search-kill))
  :custom
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (add-to-list 'ivy-sort-functions-alist
               '(counsel-recentf . file-newer-than-file-p))
  :config
  (ivy-mode))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1)) ;; this gets us descriptions in M-x.

(use-package ivy-xref
  :ensure t
  :after ivy
  :init
  ;; xref initialization is different in Emacs 27 - there are two different
  ;; variables which can be set rather than just one
  (when (>= emacs-major-version 27)
    (setq xref-show-definitions-function #'ivy-xref-show-defs))
  ;; Necessary in Emacs <27. In Emacs 27 it will affect all xref-based
  ;; commands other than xref-find-definitions (e.g. project-find-regexp)
  ;; as well
  (setq xref-show-xrefs-function #'ivy-xref-show-xrefs))

(use-package counsel
  :commands (counsel-switch-buffer)
  :config
  (counsel-mode 1))

(use-package clojure-mode
  :mode "\\.\\(clj\\|cljs\\|cljc\\)\\''")
(use-package lua-mode
  :mode "\\.lua\\'")
(use-package markdown-mode
  :mode "\\.md\\'")
(use-package fennel-mode
  :mode "\\.fnl\\'")
(use-package terraform-mode
  :mode "\\.tf\\'")

(use-package highlight-indent-guides
  :ensure t
  :diminish t
  :config
  (setq highlight-indent-guides-method 'column)
  :init
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

(use-package rainbow-delimiters
  :ensure t
  :diminish t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(setq compilation-scroll-output t)

(defun mw/npm-run-target (target options)
  "Run npm run TARGET with OPTIONS."
  (interactive)
  (compile
   (mw/build-command " npm run " target options t t)))

(defun mw/npm-run-watch-tailwind ()
  "Run the mvn targets clean and compile."
  (interactive)
  (mw/npm-run-target "tailwindw" ""))

(use-package yaml
  :mode "\\.yml\\'")
(use-package docker)
(use-package dockerfile-mode)

(nvmap :keymaps 'sql-mode-map :prefix "SPC"
       "m p" '(:which-key "Connections")
       "m p c" '(sql-postgres :which-key "Connect to postgres")
       "m e r" '(sql-send-region :which-key "Eval sql region")
       "m e e" '(sql-send-paragraph :which-key "Eval sql paragraph"))

(setq sql-ms-program "sqlcmd")
(setq sql-ms-options '())

(setq sql-connection-alist
      '((local (sql-product 'postgres)
               (sql-port 5432)
               (sql-server "localhost"))
        (local5433 (sql-product 'postgres)
                   (sql-port 5433)
                   (sql-server "localhost"))))

(defun ms-connect (connection)
  (setq sql-product 'ms)
  (sql-connect connection))

(defun psql-connect (connection)
  (setq sql-product 'postgres)
  (sql-connect connection))

(defun psql-local ()
  (interactive)
  (psql-connect 'local))

(defun psql-local5433 ()
  (interactive)
  (psql-connect 'local5433))

(use-package smartparens
  :ensure t
  :diminish t
  :init
  (add-hook 'org-mode-hook #'smartparens-mode)
  (add-hook 'clojure-mode-hook #'smartparens-mode)
  (add-hook 'fennel-mode-hook #'smartparens-mode)
  (add-hook 'cider-repl-mode-hook #'smartparens-mode)
  (add-hook 'emacs-lisp-mode-hook #'smartparens-mode))

(defmacro def-pairs (pairs)
  "Define functions for pairing. PAIRS is an alist of (NAME . STRING)
conses, where NAME is the function name that will be created and
STRING is a single-character string that marks the opening character.

  (def-pairs ((paren . \"(\")
              (bracket . \"[\"))

defines the functions WRAP-WITH-PAREN and WRAP-WITH-BRACKET,
respectively."
  `(progn
     ,@(cl-loop for (key . val) in pairs
             collect
             `(defun ,(read (concat
                             "wrap-with-"
                             (prin1-to-string key)
                             "s"))
                  (&optional arg)
                (interactive "p")
                (sp-wrap-with-pair ,val)))))

(def-pairs ((paren . "(")
            (bracket . "[")
            (brace . "{")
            (single-quote . "'")
            (double-quote . "\"")
            (back-quote . "`")))

(nvmap :keymaps 'smartparens-mode-map :prefix "SPC"
  "s"   '(:which-key "smartparens")
  "s s"   '(:which-key "slurp")
  "s s b" '(sp-backward-slurp-sexp :which-key "Backward slurp sexp")
  "s s f" '(sp-forward-slurp-sexp :which-key "Forward slurp sexp")

  "s b"   '(:which-key "barf")
  "s b b" '(sp-backward-barf-sexp :which-key "Backward barf sexp")
  "s b f" '(sp-forward-barf-sexp :which-key "Forward barf sexp")

  "s u"   '(:which-key "unwrap")
  "s u b" '(sp-backward-unwrap-sexp :which-key "Unwrap expression")
  "s u r" '(sp-raise-sexp :which-key "Raise expression")

  "s w"   '(:which-key "wrap")
  "s w ("  '(wrap-with-parens :which-key "Wrap with parens")
  "s w )"  '(wrap-with-parens :which-key "Wrap with parens")
  "s w ["  '(wrap-with-brackets :which-key "Wrap with brackets")
  "s w ]"  '(wrap-with-brackets :which-key "Wrap with brackets")
  "s w {"  '(wrap-with-braces :which-key "Wrap with braces")
  "s w }"  '(wrap-with-braces :which-key "Wrap with braces")
  "s w \""  '(wrap-with-double-quotes :which-key "Wrap with double quotes")
  "s w '"  '(wrap-with-single-quotes :which-key "Wrap with single quotes")
  "s w _"  '(wrap-with-underscores :which-key "Wrap with underscores")
  "s w `"  '(wrap-with-back-quotes :which-key "Wrap with backticks"))

(use-package cider
  :hook (cider-mode . clojure-mode))

(defun mw/nrepl-reset ()
  (interactive)
  (cider-interactive-eval
   "(dev/reset)"))

(defun mw/nrepl-dev ()
  (interactive)
  (cider-interactive-eval
   "(user/dev)"))

(defun mw/nrepl-go ()
  (interactive)
  (cider-interactive-eval
   "(dev/go)"))

(defun mw/nrepl-init-db ()
  (interactive)
  (cider-interactive-eval
   "(use 'db) (db/init-schema)"))

(defun mw/nrepl-migrate-db ()
  (interactive)
  (cider-interactive-eval
   "(use 'db) (db/migrate-schema)"))

(nvmap :keymaps 'clojure-mode-map :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")
  "m r" '(:which-key "reloaded")

  "m r g" '(mw/nrepl-go :which-key "Go")
  "m r d" '(mw/nrepl-dev :which-key "Dev")
  "m r r" '(mw/nrepl-reset :which-key "Reset")
  "m r m" '(mw/nrepl-migrate-db :which-key "Migrate DB")
  "m r i" '(mw/nrepl-init-db :which-key "Init DB")

  "m e b" '(cider-eval-buffer :which-key "Cider eval buffer")
  "m e e" '(cider-eval-defun-at-point :which-key "Cider eval root expressions")
  "m e E" '(cider-eval-last-sexp :which-key "Cider eval expressions")

  "m t" '(:which-key "test")
  "m t p" '(cider-test-run-project-tests :which-key "Cider run project tests")
  "m t n" '(cider-test-run-ns-tests :which-key "Cider run ns tests")

  "m s" '(:which-key "sesman")
  "m s I" '(cider-jack-in-cljs :which-key "Cider jack in cljs")
  "m s i" '(cider-jack-in :which-key "Cider jack in"))

(nvmap :keymaps 'fennel-mode-map :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")

  "m e b" '(fennel-reload :which-key "Cider eval buffer")
  "m e e" '(fennel-eval-toplevel-form :which-key "Cider eval root expressions")
  "m e E" '(fennel-eval-last-sexp :which-key "Cider eval expressions")

  "m s" '(:which-key "sesman")
  "m s i" '(fennel-repl :which-key "Fennel REPL"))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-clojure-custom-server-command '("bash" "-c" "clojure-lsp"))
  (dolist (m '(clojure-mode
               clojurec-mode
               clojurescript-mode
               clojurex-mode))
    (add-to-list 'lsp-language-id-configuration `(,m . "clojure")))
  (add-to-list 'lsp-language-id-configuration '(fennel-mode . "fennel"))
  (lsp-register-client (make-lsp-client
                      :new-connection (lsp-stdio-connection "fennel-ls")
                      :activation-fn (lsp-activate-on "fennel")
                      :server-id 'fennel-ls))
  (setq lsp-enable-indentation nil)
  (setq lsp-semantic-tokens-enable nil)
  (setq lsp-sqls-workspace-config-path nil)
  (setq lsp-sqls-connections
      '(((driver . "postgresql") (dataSourceName . "host=127.0.0.1 port=5432 user=bags password=bags dbname=bags sslmode=disable"))
       ((driver . "postgresql") (dataSourceName . "host=127.0.0.1 port=5432 user=pelly password=pelly dbname=pelly sslmode=disable"))
       ((driver . "postgresql") (dataSourceName . "host=127.0.0.1 port=5432 user=abv password=abv dbname=abv sslmode=disable")))))

(use-package lsp-ui
  :after lsp)

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(add-hook 'sql-mode-hook 'lsp)
(add-hook 'clojure-mode-hook 'lsp)
(add-hook 'clojurescript-mode-hook 'lsp)
(add-hook 'clojurec-mode-hook 'lsp)
(add-hook 'fennel-mode-hook 'lsp)
(setq read-process-output-max (* 3 1024 1024))

(nvmap :prefix ""
  "K" '(lsp-ui-doc-glance :which-key "Lsp Documentation"))

(nvmap :prefix "SPC"
  "l"   '(:which-key "lsp")
  "l g" '(:which-key "goto")
  "l g d" '(lsp-find-definition :which-key "Find definition")
  "l d" '(:which-key "diag")
  "l d r" '(lsp-find-references :which-key "Find references")
  "l d a" '(lsp-execute-code-action :which-key "LSP code actions")
  "l d D" '(lsp-treemacs-errors-list :which-key "Diagnotics"))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package company)
(global-company-mode)

(use-package yasnippet)
(yas-global-mode 1)

(use-package magit
  :commands (magit-status)
  :config
  (setq magit-display-buffer-function #'display-buffer))

(nvmap :prefix "SPC" :keymaps 'override
  "g"   '(:which-key "git")
  "g g" '(counsel-git-grep :which-key "Grep git files")
  "g f" '(magit-find-file :which-key "Git files")
  "g F" '(magit-pull :which-key "Magit pull -rebase")
  "g P" '(magit-push :which-key "Magit push")
  "g s" '(magit-status :which-key "Magit status"))

(use-package git-gutter)
(global-git-gutter-mode +1)

(use-package org
  :mode ("\\.org\\'" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)

(use-package org-bullets
  :after org
  :mode ("\\.org\\'" . org-mode)
  :init (org-bullets-mode 1))

(require 'ob-clojure)
(setq org-babel-clojure-backend 'babashka)
(with-eval-after-load 'org
(org-babel-do-load-languages
 'org-babel-load-languages
 '((sql . t)
   (clojure . t)
   (shell . t))))

(nvmap :keymaps 'org-mode-map :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")
  "m e E" '(org-babel-execute-src-block :which-key "Execute source block"))

(use-package projectile
  :config
  (projectile-global-mode 1)
  :init
  (when (file-directory-p "~/src")
    (setq projectile-project-search-path '("~/src")))
  (setq projectile-switch-project-action #'projectile-dired))

(nvmap :keymaps 'override :prefix "SPC"
       "p"     '(:which-key "projects")
       "p f"   '(projectile-find-file :which-key "Find file"))

(setq scroll-conservatively 101) ;; value greater than 100 gets rid of half page jumping
(setq mouse-wheel-scroll-amount '(3 ((shift) . 3))) ;; how many lines at a time
(setq mouse-wheel-progressive-speed t) ;; accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(use-package vterm
  :commands (vterm))

(setq-default explicit-shell-file-name "/bin/zsh")

(setq shell-file-name "/bin/zsh"
      vterm-shell "/bin/zsh"
      vterm-max-scrollback 9000)

(nvmap :keymaps '(override vterm-map-mode) :prefix "C-c"
  "C-c"   '(vterm--self-insert :which-key "Literal Ctrl C"))

(winner-mode 1)

(add-to-list 'display-buffer-alist
     '("\*vterm\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*compilation\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*Compile-Log\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*Flymake\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*cider-repl\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*Fennel REPLl\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*sqls results\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*SQL\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(nvmap :keymaps 'override :prefix "SPC"
       "w"     '(:which-key "windows")
       "w c"   '(evil-window-delete :which-key "Close window")
       "w n"   '(evil-window-new :which-key "New window")
       "w S"   '(evil-window-split :which-key "Horizontal split window")
       "w s"   '(evil-window-vsplit :which-key "Vertical split window")
       ;; Window motions
       "w h"   '(evil-window-left :which-key "Window left")
       "w j"   '(evil-window-down :which-key "Window down")
       "w k"   '(evil-window-up :which-key "Window up")
       "w l"   '(evil-window-right :which-key "Window right")
       "w w"   '(evil-window-next :which-key "Goto next window"))

(use-package which-key
  :init
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit t
        which-key-separator " → " ))
(which-key-mode)
(which-key-setup-minibuffer)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 5 1000 1000))
