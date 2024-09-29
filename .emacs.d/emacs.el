;;; emacs.el --- My EMACS config -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; An EMACS config that is ok for me!

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:
(setq vc-follow-symlinks t)

(require 'package)
(add-to-list 'package-archives
       '("melpa" . "https://melpa.org/packages/"))
;;(package-refresh-contents)
(package-initialize)

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

;; This sets $MANPATH, $PATH and exec-path from your shell,
;; but only when executed in a GUI frame on OS X and Linux.
(use-package exec-path-from-shell
  :functions exec-path-from-shell-initialize
  :ensure t
  :init
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package evil
  :ensure t
  :defines
  evil-want-integration
  evil-want-keybinding
  evil-vsplit-window-right
  evil-split-window-below
  evil-search-module
  :functions evil-mode
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t
        evil-search-module 'evil-search)
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :defines evil-collection-mode-list
  :functions evil-collection-init
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  :custom (evil-collection-setup-minibuffer t)
  :init (evil-collection-init))

(use-package evil-goggles
  :ensure t
  :after evil-cleverparens
  :functions evil-goggles-mode
  :defines evil-goggles--commands
  :config
  (add-to-list 'evil-goggles--commands '(evil-cp-yank :face evil-goggles-yank-face :switch evil-goggles-enable-yank :advice evil-goggles--generic-async-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-yank-line :face evil-goggles-yank-face :switch evil-goggles-enable-yank :advice evil-goggles--generic-async-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-yank-sexp :face evil-goggles-yank-face :switch evil-goggles-enable-yank :advice evil-goggles--generic-async-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-yank :face evil-goggles-yank-face :switch evil-goggles-enable-yank :advice evil-goggles--generic-async-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-yank :face evil-goggles-yank-face :switch evil-goggles-enable-yank :advice evil-goggles--generic-async-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-delete :face evil-goggles-delete-face :switch evil-goggles-enable-delete :advice evil-goggles--delete-line-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-delete-line :face evil-goggles-delete-face :switch evil-goggles-enable-delete :advice evil-goggles--delete-line-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-change :face evil-goggles-change-face :switch evil-goggles-enable-change :advice evil-goggles--generic-blocking-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-change-line :face evil-goggles-change-face :switch evil-goggles-enable-change :advice evil-goggles--generic-blocking-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-change-sexp :face evil-goggles-change-face :switch evil-goggles-enable-change :advice evil-goggles--generic-blocking-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-change-enclosing :face evil-goggles-change-face :switch evil-goggles-enable-change :advice evil-goggles--generic-blocking-advice))
  (add-to-list 'evil-goggles--commands '(evil-cp-change-whole-line :face evil-goggles-change-face :switch evil-goggles-enable-change :advice evil-goggles--generic-blocking-advice))
  (evil-goggles-mode))

(use-package evil-surround
  :ensure t
  :after evil
  :functions global-evil-surround-mode
  :config
  (global-evil-surround-mode 1))

(use-package undo-tree
  :ensure t
  :after evil
  :defines
  undo-tree-history-directory-alist
  undo-tree-auto-save-history
  :functions evil-set-undo-system global-undo-tree-mode
  :diminish
  :config
  (evil-set-undo-system 'undo-tree)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  (setq undo-tree-auto-save-history t)
  (global-undo-tree-mode 1))

(global-set-key (kbd "<escape>") 'keyboard-quit)

(use-package general
  :ensure t
  :functions
  general-evil-setup
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

(use-package all-the-icons
  :ensure t)

(use-package dashboard
  :ensure t
  :defines
  dashboard-set-heading-icons
  dashboard-set-file-icons
  dashboard-projects-backend
  dashboard-icon-type
  dashboard-banner-logo-title
  dashboard-startup-banner
  dashboard-center-content
  dashboard-vertically-center-content
  dashboard-items
  :functions dashboard-setup-startup-hook
  :init
  (setq dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-projects-backend 'projectile
        dashboard-icon-type 'nerd-icons
        dashboard-banner-logo-title "emacs!"
        dashboard-startup-banner "~/.emacs.d/emacs.png"
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-items '((recents . 14)
                          (projects . 9)))
  (dashboard-setup-startup-hook))

(use-package doom-modeline
  :ensure t
  :functions doom-modeline-mode
  :init
  (doom-modeline-mode 1))

(use-package catppuccin-theme
  :ensure t
  :init
  (load-theme 'catppuccin :no-confirm))

(setq switch-to-buffer-obey-display-actions t)

(nvmap :prefix "SPC" :keymaps 'override
   "b"     '(:which-key "buffers")
   "b x"   '((lambda () (interactive) (kill-this-buffer) (evil-window-delete)) :which-key "Kill buffer")
   "b l"   '(counsel-switch-buffer :which-key "List buffers")
   "b n"   '(next-buffer :which-key "Next buffer")
   "b n"   '(rename-buffer :which-key "Rename buffer")
   "b g"   '(swiper :which-key "Grep")
   "b p"   '(previous-buffer :which-key "Previous buffer"))

(nvmap :prefix "SPC" :keymaps 'override
   "c"     '(:which-key "processes")
   "c l"   '(list-processes :which-key "List processes"))

(setq-default indent-tabs-mode nil)

(use-package ws-butler
  :ensure t
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
  :ensure t
  :commands (sudo-edit sudo-edit-find-file sudo-edit))

(set-face-attribute 'default nil
  :font "JetBrains Mono"
  :height 92
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "JetBrains Mono"
  :height 92
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono"
  :height 92
  :weight 'medium)
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

(use-package smex
  :ensure t)
(use-package ivy
  :ensure t
  :defer 0.1
  :defines
  evil-insert-state-map
  ivy-minibuffer-map
  ivy-switch-buffer-map
  ivy-reverse-i-search-map
  :functions ivy-mode
  :diminish
  :bind
  (("C-s" . swiper)
   :map evil-insert-state-map
   ("C-k" . ivy-previous-line)
   ("C-j" . ivy-next-line)
   :map ivy-minibuffer-map
   ("TAB" . ivy-partial)
   ("C-l" . ivy-alt-done)
   ("C-j" . ivy-next-linae)
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
  (setq ivy-count-format "(%d/%d) "
        ivy-use-virtual-buffers t
        enable-recursive-minibuffers t)
  (add-to-list 'ivy-sort-functions-alist
               '(counsel-recentf . file-newer-than-file-p))
  :config
  (ivy-mode))

(use-package ivy-rich
  :ensure t
  :functions ivy-rich-mode
  :after ivy
  :init
  (ivy-rich-mode 1)) ;; this gets us descriptions in M-x.

(use-package ivy-xref
  :ensure t
  :defines
  xref-show-definitions-function
  xref-show-xrefs-function
  :functions
  ivy-xref-show-xrefs
  ivy-xref-show-defs
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
  :ensure t
  :commands (counsel-switch-buffer)
  :functions counsel-mode
  :config
  (counsel-mode 1))

(load-file
 (expand-file-name
  "clojure.el"
  user-emacs-directory))

(use-package fennel-mode
  :ensure t
  :mode "\\.fnl\\'")

(use-package terraform-mode
  :ensure t
  :mode "\\.tf\\'")

(use-package highlight-indent-guides
  :ensure t
  :diminish t
  :defines highlight-indent-guides-method
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom (highlight-indent-guides-method 'column))

(use-package rainbow-delimiters
  :ensure t
  :diminish t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package yaml
  :ensure t
  :mode "\\.yml\\'")

(use-package docker
  :ensure t)

(use-package dockerfile-mode
  :ensure t)

(use-package smartparens
  :ensure t
  :diminish t
  :config
  ;; Sane defaults for smartparens, like do not double ' for lisp dialects
  (require 'smartparens-config)
  :hook ((clojure-mode . smartparens-strict-mode)
         (cider-repl-mode . smartparens-mode)
         (fennel-mode . smartparens-strict-mode)
         (emacs-lisp-mode . smartparens-strict-mode)))

(use-package evil-cleverparens
  :ensure t
  :functions evil-cleverparens-mode
  :init
  (add-hook 'smartparens-enabled-hook #'evil-cleverparens-mode))

(nvmap :keymaps '(smartparens-mode-map smartparens-strict-mode-map) :prefix "SPC"
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

(nvmap :keymaps 'fennel-mode-map :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")

  "m e b" '(fennel-reload :which-key "Fennel eval buffer")
  "m e e" '(fennel-eval-toplevel-form :which-key "Fennel eval root expressions")
  "m e E" '(fennel-eval-last-sexp :which-key "Fennel eval expressions")

  "m s" '(:which-key "sesman")
  "m s i" '(fennel-repl :which-key "Fennel REPL"))

(use-package company
  :ensure t
  :functions global-company-mode
  :init
  (global-company-mode))

(use-package yasnippet
  :ensure t
  :functions yas-global-mode
  :init
  (yas-global-mode 1))

(use-package magit
  :ensure t
  :defines magit-display-buffer-function
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

(use-package git-gutter
  :ensure t
  :functions global-git-gutter-mode
  :init
  (global-git-gutter-mode +1))

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)

(use-package org-bullets
  :ensure t
  :functions org-bullets-mode
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
  :ensure t
  :defines
  projectile-project-search-path
  projectile-switch-project-action
  :functions
  projectile-global-mode
  projectile-dired
  :config
  (projectile-global-mode 1)
  :init
  (when (file-directory-p "~/src")
    (setq projectile-project-search-path '("~/src")))
  (setq projectile-switch-project-action #'projectile-dired))

(nvmap :keymaps 'override :prefix "SPC"
       "p"     '(:which-key "projects")
       "p l"   '(projectile-switch-to-buffer :which-key "Buffer list")
       "p r"   '(projectile-recentf :which-key "Recent files")
       "p f"   '(projectile-find-file :which-key "Find file"))


(setq-default explicit-shell-file-name "/bin/zsh")
(use-package vterm
  :ensure t
  :commands (vterm)
  :custom
  (setq shell-file-name "/bin/zsh"
        vterm-shell "/bin/zsh"
        vterm-max-scrollback 9000))

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
     '("\*Help\*"
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
     '("\*Org-Babel Error Output\*"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*Process List\*"
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
     '("\*tail"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*docker"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("\*aws"
       (display-buffer-in-side-window)
       (window-height . 0.33)
       (side . bottom)
       (slot . 0)))

(add-to-list 'display-buffer-alist
     '("magit"
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
  :ensure t
  :defines
  which-key-side-window-location
  which-key-sort-order
  which-key-sort-uppercase-first
  which-key-add-column-padding
  which-key-max-display-columns
  which-key-min-display-lines
  which-key-side-window-slot
  which-key-side-window-max-height
  which-key-idle-delay
  which-key-max-description-length
  which-key-allow-imprecise-window-fit
  which-key-separator
  :functions
  which-key-key-order-alpha
  which-key-mode
  which-key-setup-minibuffer
  :config
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
        which-key-separator " → " )
  :init
  (which-key-mode)
  (which-key-setup-minibuffer))

(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(load-file
 (expand-file-name
  "shell.el"
  user-emacs-directory))

(load-file
 (expand-file-name
  "lsp.el"
  user-emacs-directory))

(load-file
 (expand-file-name
  "compilation.el"
  user-emacs-directory))

(load-file
 (expand-file-name
  "sql.el"
  user-emacs-directory))

(load-file
 (expand-file-name
  "aws.el"
  user-emacs-directory))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 5 1000 1000))

;;; emacs.el ends here
