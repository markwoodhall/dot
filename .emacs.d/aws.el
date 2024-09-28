(defun mw/aws-profiles ()
  "Get a list of configured AWS profiles."
  (mw/bash
   "cat ~/.aws/config | grep '\\[profile ' | sed -e 's/\\[//g' -e 's/\\]//g' -e 's/profile //g'"))

(defun mw/aws-sqs-queue-urls (profile)
  "Get a list of SQS queue urls for an AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " sqs list-queues | jq -r '.QueueUrls[]'")))

(defun mw/aws-logs-log-groups (profile)
  "Get a list of CloudWatch log groups for an AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " logs describe-log-groups | jq  -r '.logGroups[].logGroupName'")))

(defun mw/aws-sqs-get-queue-attributes (profile)
  "Get attributes for an SQS queue belonging to PROFILE."
  (interactive
   (list
    (completing-read "Profile: " (mw/aws-profiles))))
  (let* ((queue-url (completing-read "Queue Url: " (mw/aws-sqs-queue-urls profile)))
         (attributes (completing-read "Attributes: " '("All")))
         (buffer-name (concat "aws sqs get-queue-attributes " profile " " queue-url " " attributes)))
    (make-comint buffer-name "aws" nil "sqs" "get-queue-attributes" "--profile" profile "--queue-url" queue-url "--attribute-names" attributes)
    (pop-to-buffer (concat "*" buffer-name "*"))))

(defun mw/aws-logs-filter-log-events (profile)
  "Get logs for a CLoudWatch log group belonging to PROFILE."
  (interactive
   (list
    (completing-read "Profile: " (mw/aws-profiles))))
  (let* ((log-group (completing-read "Log group: " (mw/aws-logs-log-groups profile)))
         (pattern (completing-read "Filter pattern: " '("ERROR" , "INFO")))
         (start-time (completing-read "Start time: " '("15 minutes ago" "30 minutes ago" "1 hour ago" "2 hours ago")))
         (buffer-name (concat "aws logs filter-log-events " profile " " log-group " " pattern))
         (start-time-val (car (mw/bash (concat "date -d '" start-time  "' +%s000")))))
    (make-comint buffer-name "aws" nil "logs" "filter-log-events" "--start-time" start-time-val "--profile" profile "--log-group-name" log-group "--filter-pattern" pattern)
    (pop-to-buffer (concat "*" buffer-name "*"))))
