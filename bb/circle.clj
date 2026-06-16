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

(defn workflow-status [pipeline-id]
  (let [url (str/join "/" [api "pipeline" pipeline-id "workflow"])]
    (->
      (http/get url
                {:headers {"Circle-Token" (-> config :token)}})
      :body
      (json/parse-string true)
      :items
      first
      :status)))

(doseq [[vc org project] (-> config :projects)]
  (let [status (try (-> (latest-pipeline vc org project)
                        workflow-status)
                    (catch Exception e
                      (eprintln (ex-data e))
                      "failed-to-determine"))
        output (case status
                 ("running" "on_hold")  
                 (str vc "/" org "/" project " " (colorize yellow status))
                 "success" 
                 (str vc "/" org "/" project " " (colorize green status))
                 ("failed" 
                  "error" 
                  "failing" 
                  "canceled" 
                  "unauthorized"
                  "failed-to-determine") 
                 (str vc "/" org "/" project " " (colorize red status) )
                 (str vc "/" org "/" project " " status))]
    (println output)))
