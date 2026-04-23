(setq sql-connection-alist
      '((local (sql-product 'postgres)
               (sql-port 5432)
               (sql-server "localhost"))
        (local-5431 (sql-product 'postgres)
                    (sql-port 5431)
                    (sql-server "localhost"))
        (local-5432 (sql-product 'postgres)
                    (sql-port 5432)
                    (sql-server "localhost"))
        (local-5433 (sql-product 'postgres)
                   (sql-port 5433)
                   (sql-server "localhost"))))

(defun mw/psql-connect (product connection)
  (setq sql-product 'postgres)
  (sql-connect connection))

(defun mw/psql-local ()
  (interactive)
  (mw/psql-connect 'postgres 'local))

(defun mw/psql-local-5431 ()
  (interactive)
  (mw/psql-connect 'postgres 'local-5431))

(defun mw/psql-local-5432 ()
  (interactive)
  (mw/psql-connect 'postgres 'local-5432))

(defun mw/psql-local-5433 ()
  (interactive)
  (mw/psql-connect 'postgres 'local-5433))

(defun mw/sqls-init-dir-locals ()
  "Write an `lsp-sqls-connections' entry to .dir-locals.el at the project root.
Prompts for connection details so secrets stay out of the global config."
  (interactive)
  (let* ((root (or (when (fboundp 'project-current)
                     (when-let ((proj (project-current)))
                       (project-root proj)))
                   (locate-dominating-file default-directory ".git")
                   default-directory))
         (driver (completing-read "Driver: " '("postgresql" "mysql" "mssql") nil t nil nil "postgresql"))
         (host (read-string "Host: " "127.0.0.1"))
         (port (read-string "Port: " (if (string= driver "postgresql") "5432" "3306")))
         (user (read-string "User: "))
         (password (read-passwd "Password: "))
         (dbname (read-string "Database: "))
         (dsn (format "host=%s port=%s user=%s password=%s dbname=%s sslmode=disable"
                      host port user password dbname))
         (file (expand-file-name ".dir-locals.el" root))
         (snippet `((sql-mode . ((lsp-sqls-connections
                                  . (((driver . ,driver)
                                      (dataSourceName . ,dsn)))))))))
    (if (file-exists-p file)
        (progn
          (find-file file)
          (message "%s already exists. Paste this snippet: %S" file snippet))
      (with-temp-file file
        (insert ";; -*- mode: emacs-lisp -*-\n")
        (pp snippet (current-buffer)))
      (message "Wrote %s" file))))

(nvmap :keymaps 'sql-mode-map :prefix "SPC"
       "m c" '(:which-key "Connections")
       "m c p" '(sql-postgres :which-key "Connect to postgres")
       "m c m" '(sql-postgres :which-key "Connect to mssql")
       "m c b" '(sql-set-sqli-buffer :which-key "Connect to SQLi buffer")
       "m e r" '(sql-send-region :which-key "Eval sql region")
       "m e e" '(sql-send-paragraph :which-key "Eval sql paragraph")
       "m e q" '(lsp-execute-code-action :which-key "Run sqls code action (Execute Query)")
       "m D"   '(mw/sqls-init-dir-locals :which-key "Create .dir-locals.el for sqls"))

(setq sql-ms-program "sqlcmd")
(setq sql-ms-options '())

(with-eval-after-load 'company
  (require 'company-keywords)
  (unless (assq 'sql-interactive-mode company-keywords-alist)
    (push '(sql-interactive-mode . sql-mode) company-keywords-alist))
  (defun mw/sqli-company-setup ()
    (setq-local company-backends
                '((company-keywords company-dabbrev-code company-dabbrev))))
  (add-hook 'sql-interactive-mode-hook #'mw/sqli-company-setup))
