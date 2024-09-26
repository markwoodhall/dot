(use-package clojure-mode
  :mode "\\.\\(clj\\|cljs\\|cljc\\)\\''")

(use-package cider
  :hook (cider-mode . clojure-mode))

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

  "m r r" '(cider-ns-refresh :which-key "Cider refresh")
  "m r g" '(mw/nrepl-go :which-key "Go")
  "m r d" '(mw/nrepl-dev :which-key "Dev")
  "m r x" '(mw/nrepl-reset :which-key "Reset")
  "m d m" '(mw/nrepl-migrate-db :which-key "Migrate DB")
  "m d i" '(mw/nrepl-init-db :which-key "Init DB")

  "m e b" '(cider-eval-buffer :which-key "Cider eval buffer")
  "m e e" '(cider-eval-defun-at-point :which-key "Cider eval root expressions")
  "m e E" '(cider-eval-last-sexp :which-key "Cider eval expressions")

  "m t" '(:which-key "test")
  "m t p" '(cider-test-run-project-tests :which-key "Cider run project tests")
  "m t n" '(cider-test-run-ns-tests :which-key "Cider run ns tests")

  "m s" '(:which-key "sesman")
  "m s I" '(cider-jack-in-cljs :which-key "Cider jack in cljs")
  "m s i" '(cider-jack-in :which-key "Cider jack in"))
