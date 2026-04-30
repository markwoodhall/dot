;;; aws.el --- A comint package for the AWS cli -*- lexical-binding: t -*-

;; Copyright © 2024-2024 Mark Woodhall and contributors

;;; Commentary:

;; Provides a range of functions that wrap the AWS cli, providing
;; completion and output in comint.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(declare-function mw/bash "shell.el")

(defun mw/aws-profiles ()
  "Get a list of configured AWS profiles."
  (mw/bash
   "cat ~/.aws/config | grep '\\[profile ' | sed -e 's/\\[//g' -e 's/\\]//g' -e 's/profile //g'"))

;; SQS

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

;; LOGS

(defun mw/aws-logs-log-groups (profile)
  "Get a list of CloudWatch log groups for an AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " logs describe-log-groups | jq  -r '.logGroups[].logGroupName'")))

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

;; ECS

(defun mw/aws-ecs-clusters (profile)
  "Get a list of ECS Clusters for an AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " ecs list-clusters | jq -r '.clusterArns[]'")))

(defun mw/aws-ecs-services (profile cluster)
  "Get a list of ECS Services for an ECS CLUSTER and AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " ecs list-services --cluster " cluster " | jq -r '.serviceArns[]'")))

(defun mw/aws-ecs-tasks (profile cluster)
  "Get a list of ECS Tasks for an ECS CLUSTER and AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " ecs list-tasks --cluster " cluster " | jq -r '.taskArns[]'")))

(defun mw/aws-ecs-describe-tasks (profile)
  "Describe an ECS Task belonging to PROFILE."
  (interactive
   (list
    (completing-read "Profile: " (mw/aws-profiles))))
  (let* ((cluster (completing-read "Cluster: " (mw/aws-ecs-clusters profile)))
         (task (completing-read "Task: " (mw/aws-ecs-tasks profile cluster)))
         (buffer-name (concat "aws ecs describe-task " profile " " cluster " " task)))
    (make-comint buffer-name "aws" nil "ecs" "describe-tasks" "--profile" profile "--cluster" cluster "--tasks" task)
    (pop-to-buffer (concat "*" buffer-name "*"))))

;; RDS

(defun mw/aws-rds-instances (profile)
  "Get a list of RDS Instances for an AWS PROFILE."
  (mw/bash
   (concat "aws --profile " profile " rds describe-db-instances | jq -r '.DBInstances[].DBInstanceIdentifier'")))

;;; aws.el ends here
