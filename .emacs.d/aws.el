(defun mw/aws-profiles ()
  "Get a list of configured AWS profiles."
  (mw/bash
   "cat ~/.aws/config | grep '\\[profile ' | sed -e 's/\\[//g' -e 's/\\]//g' -e 's/profile //g'"))

(defun mw/aws-sqs-queue-urls (profile)
  "Get a list of SQS queue urls for an AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " sqs list-queues | jq -r '.QueueUrls[]'")))

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
