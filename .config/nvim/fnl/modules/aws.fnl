(local aws {})
(local util (require :util))

(set aws.setup 
     (fn []))

(fn get-command-value [v c]
  (util.first (util.split (util.second (util.split c (.. v " "))) " ")))

(fn get-last-switch [c]
  (util.first (util.split (util.last (util.split c (.. " --"))) " ")))

(local get-profile (partial get-command-value "--profile"))

;; logs
(fn log-groups [command]
  (let [profile (get-profile command)]
    (if profile
      (let [lgs (vim.fn.system (.. "aws --profile " profile " logs describe-log-groups | jq '.logGroups[].logGroupName'"))]
        (util.split lgs "\n"))
      [])))

;; sqs
(fn sqs-queues [command]
  (let [profile (get-profile command)]
    (if profile
      (let [lgs (vim.fn.system (.. "aws --profile " profile " sqs list-queues | jq '.QueueUrls[]'"))]
        (util.split lgs "\n"))
      [])))

;; ecs
(fn ecs-clusters [command]
  (let [profile (get-profile command)]
    (if profile
      (let [lgs (vim.fn.system (.. "aws --profile " profile " ecs list-clusters | jq '.clusterArns[]'"))]
        (util.split lgs "\n"))
      [])))

(fn ecs-services [command]
  (let [profile (get-profile command)
        cluster (get-command-value "--cluster" command)]
    (if profile
      (let [lgs (vim.fn.system (.. "aws --profile " profile " ecs list-services --cluster " cluster " | jq '.serviceArns[]'"))]
        (util.split lgs "\n"))
      [])))

(fn ecs-tasks [command]
  (let [profile (get-profile command)
        cluster (get-command-value "--cluster" command)]
    (if (and profile cluster)
      (let [lgs (vim.fn.system (.. "aws --profile " profile " ecs list-tasks --cluster " cluster " | jq '.taskArns[]'"))]
        (util.split lgs "\n"))
      [])))

;; rds
(fn db-instances [command]
  (let [profile (get-profile command) ]
    (if profile
      (let [lgs (vim.fn.system (.. "aws --profile " profile " rds describe-db-instances | jq '.DBInstances[].DBInstanceIdentifier'"))]
        (util.split lgs "\n"))
      [])))

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
        "--log-group-name" (with-defaults (log-groups c))
        "--queue-url" (with-defaults (sqs-queues c))
        "--cluster" (with-defaults (ecs-clusters c))
        "--service-name" (with-defaults (ecs-services c))
        "--tasks" (with-defaults (ecs-tasks c))
        "--db-instance-identifier" (with-defaults (db-instances c))
        "--attribute-names" ["All"]
        "--profile" (if aws.default-profile [aws.default-profile] (profiles))
        "--start-time" ["`date -d '5 minutes ago' +%s`000"
                        "`date -d '15 minutes ago' +%s`000"
                        "`date -d '30 minutes ago' +%s`000"
                        "`date -d '45 minutes ago' +%s`000"
                        "`date -d '1 hour ago' +%s`000"
                        "`date -d '2 hour ago' +%s`000"
                        "`date -d '24 hours ago' +%s`000"]
        _ (match (get-last-switch c)
            "tasks" (with-defaults (ecs-tasks c))
            _ (with-defaults (completer (.. c ""))))))))

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
