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
