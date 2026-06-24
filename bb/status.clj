#!/usr/bin/env bb
(ns status
  (:require 
    [babashka.cli]
    [babashka.process]
    [babashka.fs]))

(def config 
  [{:path "/home/markwoodhall/feed" :auto-sync? true}
   {:path "/home/markwoodhall/src/mark/kb" :auto-sync? true}
   {:path "/home/markwoodhall/.config/nvim"}
   {:path "/home/markwoodhall/src/mark/dot"}
   {:path "/home/markwoodhall/src/mark/dotfiles"}]) 

(def cli-options {:sync {:default false :coerce :boolean}})
(def sync?
  (:sync (babashka.cli/parse-opts *command-line-args* 
                                  {:spec cli-options})))

(doseq [{:keys [path auto-sync?]} config]
  (let [status (-> (babashka.process/shell {:dir path :out :string} "git status --short" )
                   :out)]
    (when (and sync? auto-sync?)
      (println (-> (babashka.process/shell {:dir path :out :string} "git pull origin main" )
                   :out)))
    (when (seq status)
      (println path)
      (when (and sync? auto-sync?)
        (println (-> (babashka.process/shell {:dir path :out :string} "git add ." )
                     :out))
        (println (-> (babashka.process/shell {:dir path :out :string} "git commit -m \"Auto update\"" )
                     :out))
        (println (-> (babashka.process/shell {:dir path :out :string} "git push origin main" )
                     :out)))
      (println status))))
