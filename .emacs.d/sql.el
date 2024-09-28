(setq sql-connection-alist
      '((local (sql-product 'postgres)
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

(defun mw/psql-local-5433 ()
  (interactive)
  (mw/psql-connect 'postgres 'local-5433))

(nvmap :keymaps 'sql-mode-map :prefix "SPC"
       "m p" '(:which-key "Connections")
       "m p c" '(sql-postgres :which-key "Connect to postgres")
       "m e r" '(sql-send-region :which-key "Eval sql region")
       "m e e" '(sql-send-paragraph :which-key "Eval sql paragraph"))
