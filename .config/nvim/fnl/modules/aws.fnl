(local aws {})
(local util (require :util))

(set aws.setup 
     (fn []))

(fn log-groups [profile]
  (if profile
    (let [lgs (vim.fn.system (.. "aws --profile " profile " logs describe-log-groups | jq '.logGroups[].logGroupName'"))]
      (util.split lgs "\n"))
    []))

(fn profiles []
  (let [lgs (vim.fn.system "cat ~/.aws/config | grep '\\[profile ' | sed -e 's/\\[//g' -e 's/\\]//g' -e 's/profile //g'")]
    (util.split lgs "\n")))

(fn completer [command]
  (let [command (vim.fn.substitute command "Aws" "aws" "")
        lgs (vim.fn.system (.. "COMMAND_LINE='"command "' aws_completer"))]
    (util.split lgs "\n")))

(fn completion [_ c]
  (vim.fn.sort
    (let [c-parts (util.split c " ")
          with-defaults (fn [c] 
                          [(unpack c)])]
      (match (util.last c-parts)
        "--log-group-name" (with-defaults (log-groups aws.default-profile))
        "--profile" (if aws.default-profile [aws.default-profile] (profiles))
        "--start-time" ["`date -d '1 hour ago' +%s`000"
                        "`date -d '2 hour ago' +%s`000"
                        "`date -d '24 hours ago' +%s`000"]
        _ (with-defaults (completer (.. c "")))))))

(vim.api.nvim_create_user_command
  "AwsDefaultProfile"
  (fn [opts]
    (let [profile (util.first (?. opts :fargs))]
      (set aws.default-profile profile)))
  {:bang false :desc "AWS wrapper" :nargs "*"
   :complete profiles})

(vim.api.nvim_create_user_command
  "Aws"
  (fn [opts]
    (let [args (accumulate 
                 [s ""
                  _ v (ipairs (?. opts :fargs))]
                 (.. s " " v))]
      (util.pane-terminal-command (.. "aws " args))))
  {:bang false :desc "AWS wrapper" :nargs "*"
   :complete completion})

aws
