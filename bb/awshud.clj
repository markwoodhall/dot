#!/usr/bin/env bb
(ns awshud
  (:require 
    [babashka.cli]
    [babashka.process]
    [babashka.fs]
    [cheshire.core :as json]
    [clojure.string]))

(def green "\u001b[0;32m")
(def yellow "\u001b[0;33m")
(def red "\u001b[0;31m")
(def reset "\u001b[0m")

;; Command line arguments and parsing
(def cli-options {:profile {:coerse :string}
                  :json {:default false :coerce :boolean}
                  :no-color {:default false :coerce :boolean}})
(def colour?
  (not (:no-color 
         (babashka.cli/parse-opts *command-line-args* {:spec cli-options}))))

(defn colorize
  [color data]
  (if colour? 
    (str color data reset)
    data))

(def profile
  (:profile 
    (babashka.cli/parse-opts *command-line-args* {:spec cli-options})))

(def json
  (:json 
    (babashka.cli/parse-opts *command-line-args* {:spec cli-options})))

;; Display helper functions
(defn rule [width]
  (apply str (map (constantly "─") (range 0 width)))) 

(defn pad [c s n]
  (let [padded (reduce (fn [acc _]
                         (str acc c)) s (range 0 n))]
    (apply str (take n padded))))

(defn pad-left [c s n]
  (let [padded (reduce (fn [acc _]
                         (str c acc )) s (range 0 n))]
    (apply str (take-last n padded))))

(def space-pad (partial pad " "))
(def left-space-pad (partial pad-left " "))

;; aws command line
(def aws (str "aws --profile " profile))
(def ec2-cmd (str aws " ec2 describe-instances"))
(def ecs-cmd (str aws " ecs list-clusters"))
(def ecs-describe-cmd (str aws " ecs describe-clusters"))
(def ecs-tasks-cmd (str aws " ecs list-tasks"))
(def ecs-describe-tasks-cmd (str aws " ecs describe-tasks"))
(def logs-cmd (str aws " logs filter-log-events --filter-pattern ERROR --start-time "
                   ;; 15 minutes
                   (- (System/currentTimeMillis) 900000)
                   " --log-group-name "))
(def sqs-list-cmd (str aws " sqs list-queues"))
(def sqs-queue-attributes-cmd (str aws " sqs get-queue-attributes --attribute-names All --queue-url "))

;; SQS Queues
(defn ->sqs [m]
  {:arn (:QueueArn m)
   :messages (:ApproximateNumberOfMessages m)})

(defn print-queue [{:keys [arn messages]}]
  (let [messages-text (if (pos? (Integer/parseInt messages))
                        (colorize red (str "messages: " messages))
                        (colorize green (str "messages: " messages)))]
    (println 
      (str 
        (space-pad arn 80)
        (left-space-pad messages-text 51)))))

(defn print-queues [c]
  (if json
    (print c)
    (doseq [q c]
      (print-queue q))))

(defn sqs-queues []
  (let [cmd sqs-list-cmd
        out (json/parse-string 
              (-> (babashka.process/shell {:out :string} cmd) :out)
              true)
        queue-urls (:QueueUrls out)
        attributes (map (fn [u]
                          (->sqs 
                            (:Attributes 
                              (json/parse-string 
                                (-> (babashka.process/shell {:out :string} (str sqs-queue-attributes-cmd " " u)) :out)
                                true)))) queue-urls)]
    (print-queues attributes)))

;; ECS Tasks
(defn ->task [m]
  {:group (:group m)
   :desired-status (:desiredStatus m)
   :status (:lastStatus m)
   :started-at (:startedAt m)})

(defn print-task [{:keys [group desired-status status started-at]}]
  (let [group (clojure.string/replace group "service:" "")
        errors (count (:events
                        (json/parse-string
                          (-> (babashka.process/shell
                                {:out :string}
                                (str logs-cmd " " group)) :out)
                          true)))
        status (clojure.string/lower-case status)
        desired-status (clojure.string/lower-case desired-status)
        status-text (if (= desired-status status)
                      (colorize green (str "status: " status))
                      (colorize red (str "status: " status)))
        errors-text (if (pos? errors)
                      (colorize red (str "errors: " errors))
                      (colorize green (str "errors: " errors)))]
    (println 
      (str 
        (space-pad group 30)
        (space-pad errors-text 30)
        (space-pad status-text 38)
        (left-space-pad started-at 44)))))

(defn print-tasks [c]
  (if json
    (print c)
    (doseq [t c]
      (print-task t))))

(defn ecs-tasks [cluster]
  (let [cmd (str ecs-tasks-cmd " --cluster "cluster)
        out (json/parse-string 
              (-> (babashka.process/shell {:out :string} cmd) :out)
              true)
        task-arns (:taskArns out)
        describe-cmd (str ecs-describe-tasks-cmd " --cluster " cluster " --task ")
        described-tasks (reduce (fn [acc i]
                                  (concat 
                                    acc 
                                    (map ->task (:tasks 
                                                  (json/parse-string 
                                                    (-> (babashka.process/shell {:out :string} (str describe-cmd " " i)) :out)
                                                    true)))))  [] task-arns)]
    (print-tasks described-tasks)))

;; ECS Clusters
(defn ->cluster [m]
  {:arn (:clusterArn m)
   :cluster-name (:clusterName m)
   :running (:runningTasksCount m)
   :pending (:pendingTasksCount m)})

(defn print-cluster 
  [{:keys [cluster-name running pending]}]
  (println 
    (str 
      (space-pad cluster-name 30)
      (space-pad (colorize green (str "running: " running)) 30)))
  (println 
    (left-space-pad (colorize yellow (str "pending: " pending)) 51)))

(defn print-clusters [c]
  (if json
    (print c)
    (do
      (println (rule 120))
      (println "ECS Clusters")
      (println (rule 120))
      (doseq [i c]
        (print-cluster i)))))

(defn ecs-clusters []
  (let [out (json/parse-string 
              (-> (babashka.process/shell {:out :string} ecs-cmd) :out)
              true)
        cluster-arns (:clusterArns out)
        describe-cmd (str ecs-describe-cmd " --clusters " (clojure.string/join " " cluster-arns))
        described-clusters (json/parse-string 
                             (-> (babashka.process/shell {:out :string} describe-cmd) :out)
                             true)
        clusters (:clusters described-clusters)
        clusters (map ->cluster clusters)]
    (print-clusters clusters)
    clusters))

;; EC2
(defn ->instance [m]
  (let [tags (:Tags m)
        name-tags (filter (fn [t]
                            (= (:Key t) "Name")) tags)
        instance-name (-> name-tags
                          first
                          :Value)]
    {:instance-id (:InstanceId m)
     :instance-name (or instance-name (:InstanceId m))
     :launch-time (:LaunchTime m)
     :public-dns (:PublicDnsName m)
     :state (-> m :State :Name)}))

(defn print-instance 
  [{:keys [instance-name state public-dns]}]
  (let [status (if (= state "running")
                 (colorize green (space-pad state 10))
                 (colorize red (space-pad state 10)))]
    (println 
      (str 
        (space-pad instance-name 30)
        status
        (left-space-pad public-dns 80)))))

(defn print-instances [c]
  (if json
    (print c)
    (when (seq c)
      (println (rule 120))
      (println "EC2 Instances")
      (println (rule 120))
      (doseq [i c]
        (print-instance i))
      (println ""))))


(defn ec2 []
  (let [out (json/parse-string 
              (-> (babashka.process/shell {:out :string} ec2-cmd) :out)
              true)
        reservations (:Reservations out)
        instances (flatten (map :Instances reservations))
        instances (map ->instance instances)]
    (print-instances instances)))

(ec2)
(let [clusters (ecs-clusters)]
  (println "")
  (println (rule 120))
  (println "ECS Tasks")
  (println (rule 120))
  (doseq [c clusters]
    (ecs-tasks (:arn c))))

(println "")
(println (rule 120))
(println "SQS Queues")
(println (rule 120))
(sqs-queues)
