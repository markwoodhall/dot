;;; clojure.el --- My EMACS Clojure setup  -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; Setup cider and various other clojure related bindings and funtions

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

(use-package clojure-mode
  :mode "\\.\\(clj\\|cljs\\|cljc\\)\\''")

(use-package cider
  :functions
  cider-interactive-eval
  :defer t
  :config
  (setq-local lsp-completion-enable nil))

(defun mw/nrepl-reset ()
  "Run nrepl dev/reset."
  (interactive)
  (cider-interactive-eval
   "(dev/reset)"))

(defun mw/nrepl-dev ()
  "Run nrepl dev."
  (interactive)
  (cider-interactive-eval
   "(user/dev)"))

(defun mw/nrepl-go ()
  "Run nrepl dev/go."
  (interactive)
  (cider-interactive-eval
   "(dev/go)"))

(defun mw/nrepl-init-db ()
  "Run nrepl DB init."
  (interactive)
  (cider-interactive-eval
   "(use 'db) (db/init-schema)"))

(defun mw/nrepl-migrate-db ()
  "Run nrepl DB migrate."
  (interactive)
  (cider-interactive-eval
   "(use 'db) (db/migrate-schema)"))

(nvmap :keymaps 'clojure-mode-map :prefix "SPC"
  "m"   '(:which-key "major")
  "m e" '(:which-key "evaluation")
  "m d" '(:which-key "database")
  "m r" '(:which-key "reloaded")

  "m r r" '(cider-ns-reload-all :which-key "Cider refresh")
  "m r g" '(mw/nrepl-go :which-key "Go")
  "m r d" '(mw/nrepl-dev :which-key "Dev")
  "m r x" '(mw/nrepl-reset :which-key "Reset")
  "m d m" '(mw/nrepl-migrate-db :which-key "Migrate DB")
  "m d i" '(mw/nrepl-init-db :which-key "Init DB")

  "m e b" '(cider-load-buffer :which-key "Cider load buffer")
  "m e i" '(cider-interrupt :which-key "Cider eval interrupt")
  "m e E" '(cider-eval-defun-at-point :which-key "Cider eval root expression")
  "m e e" '(cider-eval-last-sexp :which-key "Cider eval expression")

  "m t" '(:which-key "test")
  "m t p" '(cider-test-run-project-tests :which-key "Cider run project tests")
  "m t n" '(cider-test-run-ns-tests :which-key "Cider run ns tests")

  "m s" '(:which-key "sesman")
  "m s X" '(cider-quit :which-key "Cider quit")
  "m s I" '(cider-jack-in-cljs :which-key "Cider jack in cljs")
  "m s i" '(cider-jack-in :which-key "Cider jack in"))

;;; clojure.el ends here
