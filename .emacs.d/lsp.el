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
  (setq lsp-enable-completion-at-point nil)
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

(setq read-process-output-max (* 3 1024 1024))

(use-package flycheck
  :init (global-flycheck-mode))
