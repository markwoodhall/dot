(use-package lsp-mode
  :hook ((clojure-mode . lsp-deferred)
         (fennel-mode . lsp-deferred))
  :defines
  lsp-language-id-configuration
  lsp-enable-indentation
  lsp-enable-completion-at-point
  lsp-ui-doc-show-with-mouse
  :functions
  lsp-register-client
  make-lsp-client
  lsp-stdio-connection
  lsp-activate-on
  :config
  (add-to-list 'lsp-language-id-configuration '(fennel-mode . "fennel"))
  (lsp-register-client (make-lsp-client
                        :new-connection (lsp-stdio-connection "fennel-ls")
                        :activation-fn (lsp-activate-on "fennel")
                        :server-id 'fennel-ls))
  (setq lsp-ui-doc-show-with-mouse nil)
  (setq lsp-enable-indentation nil)
  (setq lsp-enable-completion-at-point nil)
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :after lsp)

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(nvmap :keymaps '(lsp-mode-map) :prefix ""
  "K" '(lsp-ui-doc-glance :which-key "Lsp Documentation"))
(nvmap :prefix "SPC"
  "l"   '(:which-key "lsp")
  "l r" '(:which-key "refactor")
  "l r r" '(lsp-rename :which-key "Rename")
  "l g" '(:which-key "goto")
  "l g d" '(lsp-find-definition :which-key "Find definition")
  "l d" '(:which-key "diag")
  "l d r" '(lsp-find-references :which-key "Find references")
  "l d a" '(lsp-execute-code-action :which-key "LSP code actions")
  "l d D" '(lsp-treemacs-errors-list :which-key "Diagnotics"))

(setq read-process-output-max (* 3 1024 1024))

(use-package flycheck
  :functions global-flycheck-mode
  :init (global-flycheck-mode))
