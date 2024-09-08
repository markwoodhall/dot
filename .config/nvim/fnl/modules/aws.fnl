(local aws {})
(local util (require :util))

(set aws.setup 
     (fn []))

(fn get-command-value [v c]
  (util.first (util.split (util.second (util.split c (.. v " "))) " ")))

(fn get-last-switch [c]
  (util.first (util.split (util.last (util.split c (.. " --"))) " ")))

(fn get-primary-command [c]
  (util.second (util.split c " ")))

(fn get-sub-command [c]
  (util.nth (util.split c " ") 3))

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
        lgs (vim.fn.system (.. "COMMAND_LINE='" command "' aws_completer"))
        col (util.split lgs "\n")]
    (accumulate 
      [c []
       _ v (ipairs col)]
      [(string.gsub v "%s+" "") (unpack c)])))

(fn for-service [c service f]
  (match (get-primary-command c)
    service (f c)
    _ []))

(fn for-command [c service command f]
  (match (get-primary-command c)
    service (match (get-sub-command c)
              command (f c)
              _ [])
    _ []))

(fn completion [_ c]
  (vim.fn.sort
    (let [c-parts (util.split c " ")
          with-defaults (fn [c] 
                          [(unpack c)])]
      (match (util.last c-parts)
        "--log-group-name" (for-service c :logs log-groups) 
        "--queue-url" (for-service c :sqs sqs-queues)
        "--cluster" (for-service c :ecs ecs-clusters)
        "--service-name" (for-service c :ecs ecs-services)
        "--tasks" (for-service c :ecs ecs-tasks)
        "--db-instance-identifier" (with-defaults (db-instances c))
        "--attribute-names" (for-command c :sqs :get-queue-attributes (fn [_] ["All"])) 
        "--profile" (profiles)
        "--start-time" (for-command c :logs :filter-log-events
                                    (fn [_] ["`date -d \"5 minutes ago\" +%s000`"
                                             "`date -d \"15 minutes ago\" +%s000`"
                                             "`date -d \"30 minutes ago\" +%s000`"
                                             "`date -d \"45 minutes ago\" +%s000`"
                                             "`date -d \"1 hour ago\" +%s000`"
                                             "`date -d \"2 hour ago\" +%s000`"
                                             "`date -d \"24 hours ago\" +%s000`"])) 
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
      (util.pane-terminal-command (.. "aws" args))))
  {:bang false :desc "AWS wrapper" :nargs "*"
   :complete completion})

aws
