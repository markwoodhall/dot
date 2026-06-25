#!/usr/bin/env bb
(ns circle
  (:require [babashka.cli :as cli]
            [babashka.http-client :as http]
            [cheshire.core :as json]
            [clojure.edn :as edn]
            [clojure.string :as str]))

(def config 
  (edn/read-string 
   (slurp (str (System/getenv "HOME") "/.config/circlebb.edn"))))

(defonce api "https://circleci.com/api/v2/")

(def green "\u001b[0;32m")
(def yellow "\u001b[0;33m")
(def red "\u001b[0;31m")
(def reset "\u001b[0m")

(def cli-options {:no-color {:default false :coerce :boolean}})
(def colour?
  (not (:no-color (cli/parse-opts *command-line-args* {:spec cli-options}))))

(defn colorize
  [color data]
  (if colour? 
    (str color data reset)
    data))

(defn eprintln 
  [& args]
  (binding [*out* *err*] (apply println args)))

(defn latest-pipeline 
  [vc org project]
  (let [url (str/join "/" [api "project" vc org project "pipeline"])]
    (->
     (http/get url
               {:headers {"Circle-Token" (-> config :token)}})
     :body
     (json/parse-string true)
     :items
     first
     :id)))

(defn workflow [pipeline-id]
  (let [url (str/join "/" [api "pipeline" pipeline-id "workflow"])]
    (->
     (http/get url
               {:headers {"Circle-Token" (-> config :token)}})
     :body
     (json/parse-string true)
     :items
     first)))

(defn circle-url
  [vc org project pipeline-number workflow-id]
  (str " https://app.circleci.com/pipelines/"
       (case vc "gh" "github/" vc)
       org "/"
       project "/"
       pipeline-number
       "/workflows/" workflow-id))

(doseq [[vc org project] (-> config :projects)]
  (let [{:keys [status id pipeline_number]}
        (try (-> (latest-pipeline vc org project)
                 workflow)
             (catch Exception e
               (eprintln (ex-data e))
               "failed-to-determine"))
        output (case status
                 ("running" "on_hold")  
                 (str vc "/" org "/" project " " (colorize yellow status))
                 "success" 
                 (str vc "/" org "/" project " " (colorize green status)
                      (circle-url vc org project pipeline_number id))
                 ("failed" 
                  "error" 
                  "failing" 
                  "cancelled"
                  "unauthorized"
                  "failed-to-determine") 
                 (str vc "/" org "/" project " " (colorize red status)
                      (circle-url vc org project pipeline_number id))
                 (str vc "/" org "/" project " " status))]
    (println output)))
