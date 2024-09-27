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

(defun mw/bash (cmd)
  "Run CMD using bash and return a seq of line output."
  (split-string
   (shell-command-to-string
    (concat "bash -c \"" cmd "\"")) "\n"))

(defun mw/jq (file jq)
  "Run JQ command against json FILE."
  (mw/bash (concat "jq -r '" jq "' " file )))

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

(defun mw/docker-compose (directory)
  "Run docker compose in DIRECTORY."
  (interactive
   (list
    (read-directory-name "Directory: ")))
  (let* ((file (read-file-name "Compose file: " directory "docker-compose.yml" t "docker-compose.yml"))
         (command (completing-read "Option: " '("up" "down")))
         (buffer-name (concat "docker compose " command)))
    (make-comint buffer-name "docker" nil "compose" "-f" file command)
    (pop-to-buffer (concat "*" buffer-name "*"))))

(defun mw/docker-logs (container)
  "Run docker logs for CONTAINER."
  (interactive
   (list
    (completing-read "Container: " (mw/bash "docker ps --format '{{json .}}' | jq -r .Names"))))
  (let ((buffer-name (concat "docker logs " container)))
    (make-comint buffer-name nil "logs" container "--follow")
    (pop-to-buffer (concat "*" buffer-name "*"))))

;; docker
(defun mw/docker (command)
  "Run docker COMMAND."
  (interactive
   (list
    (completing-read "Command: " '("compose" "logs"))))
  (if (string= command "compose")
      (call-interactively #'mw/docker-compose))
  (if (string= command "logs")
      (call-interactively #'mw/docker-logs)))

;; npm
(defun mw/npm (directory command)
  "Run npm COMMAND in DIRECTORY."
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
                                   "whoami"))))
  (let* ((option (if (string= command "run")
                    (completing-read "Option: " (mw/jq
                                                 (concat directory "package.json")
                                                 ".scripts|keys[]"))
                  nil))
        (compilation-buffer-name-function
         (lambda (&rest _)
           (concat "*compilation*" "-" directory "npm-" command "-" option))))
    (compile
     (mw/build-command "npm" command option t directory nil))))

(defun mw/tail (file)
  "Run tail -f on FILE."
  (interactive
   (list
    (read-file-name "File: ")))
  (let* ((buffer-name (concat "tail " file)))
    (make-comint buffer-name "tail" nil "-f" file)
    (pop-to-buffer (concat "*" buffer-name "*"))))
