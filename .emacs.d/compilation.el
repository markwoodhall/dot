(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(setq compilation-scroll-output t)

(defun mw/read-env-file (filename replace-double-quotes)
  "Read env FILENAME and generate bash environment variable output.
Can be used to prefix a command with environment variables where applicable
REPLACE-DOUBLE-QUOTES"
  (if (file-exists-p filename)
      (let* ((data (with-temp-buffer
                     (insert-file-contents filename)
                     (buffer-string)))
             (no-comments (replace-regexp-in-string "#.*\n" "" data nil 'literal))
             (no-exp (replace-regexp-in-string (regexp-quote "EXPORT ") "" no-comments nil 'literal))
             (no-new-lines (replace-regexp-in-string (regexp-quote "\n") " " no-exp nil 'literal))
             (no-double-quotes (if replace-double-quotes
                                  (replace-regexp-in-string (regexp-quote "\"") "" no-new-lines nil 'literal)
                                  no-new-lines)))
        no-double-quotes)
    ""))

(defun mw/build-command (cmd target options change-dir dir read-env)
  "Buld a compilation command CMD with TARGET and OPTIONS.
CHANGE-DIR will produce a command that runs in the DIR specified.
READ-ENV will product a command prefixed with environment variables."
  (let ((env (if read-env (mw/read-env-file (concat dir "/.env") nil) ""))
        (cd (if change-dir (concat "cd "dir "\n")))
        (command (if cmd (concat cmd " ") ""))
        (opts (if options (concat " " options) "")))
    (concat
     cd
     env
     command target opts)))

(defun mw/build-projectile-command (cmd target options change-dir read-env)
  "Buld a compilation command CMD with TARGET and OPTIONS.
CHANGE-DIR will produce a command that runs in the project root.
READ-ENV will product a command prefixed with environment variables."
  (mw/build-command
   cmd target options change-dir (projectile-project-root) read-env))

;; npm
(defun mw/npm (directory command)
  (interactive
   (list
    (read-directory-name "Directory: ")
    (completing-read "Command: " '("access" "adduser" "audit" "bugs" "cache" "ci" "completion"
                                   "config" "dedupe" "deprecate" "diff" "dist-tag" "docs" "doctor"
                                   "edit" "exec" "explain" "explore" "find-dupes" "fund" "get" "help"
                                   "help-search" "hook" "init" "install" "install-ci-test"
                                   "install-test" "link" "ll" "login" "logout" "ls" "org" "outdated"
                                   "owner" "pack" "ping" "pkg" "prefix" "profile" "prune" "publish"
                                   "query" "rebuild" "repo" "restart" "root" "run" "run-script" "search"
                                   "set" "shrinkwrap" "star" "stars" "start" "stop" "team" "test"
                                   "token" "uninstall" "unpublish" "unstar" "update" "version" "view"
                                   "whoami"))
    ))
  ;; (shell-command-to-string command)
  (let ((runs (shell-command-to-string (concat "/usr/bin/bash -c jq '.scripts|keys[]' " directory "package.json | sed 's/\\\"//g'")))
        (option (completing-read "Option: " (cons runs '("" "watch-less" ))))
        (compilation-buffer-name-function
         (lambda (&rest _)
           (concat "*compilation*" "-" directory "npm" command "-" option))))
    (compile
     (mw/build-command " npm " command option t directory nil))))
