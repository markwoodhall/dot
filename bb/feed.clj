#!/usr/bin/env bb
(ns feed
  (:require 
    [babashka.http-client :as http]
    [clojure.data.xml :as xml]))

(def config 
  {:feeds [{:url "http://nullprogram.com/feed/" :tags [:blog :emacs]}
           {:url "https://rossabaker.com/index.xml" :tags [:blog :emacs]}]})

(defn eprintln 
  [& args]
  (binding [*out* *err*] (apply println args)))

(defn get-feed [url]
  (let [feed (->
               (babashka.http-client/get url)
               :body
               (xml/parse-str)
               :content)
        entries (flatten (map :content (filter (fn [n] (= (:tag n) :xmlns.http%3A%2F%2Fwww.w3.org%2F2005%2FAtom/entry)) feed)))
        contents (map :content (filter (fn [e] (= (:tag e) :xmlns.http%3A%2F%2Fwww.w3.org%2F2005%2FAtom/content)) entries))]
    contents))

(get-feed "https://rossabaker.com/index.xml")
