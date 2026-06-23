#!/usr/bin/env bb
(ns feed
  (:require 
    [babashka.http-client]
    [babashka.process]
    [babashka.fs]
    [clojure.string :as string]
    [clojure.edn :as edn]
    [clojure.data.xml :as xml])
  (:import 
    [java.time OffsetDateTime]
    [java.time.format DateTimeFormatter]))

(def config 
  (edn/read-string 
    (slurp (str (System/getenv "HOME") "/.config/feedbb.edn"))))

(defn ->ymd [s]
  (-> (try (OffsetDateTime/parse s)
           (catch Exception _
             (OffsetDateTime/parse s DateTimeFormatter/RFC_1123_DATE_TIME)))
      .toLocalDate
      str))

(defn eprintln 
  [& args]
  (binding [*out* *err*] (apply println args)))

(defn ->sha256 [data]
  (apply 
    str 
    (take 10 
          (-> (babashka.process/shell {:in data :out :string} "sha256sum" )
              :out))))

(defn html->org [html]
  (-> (babashka.process/shell {:in html :out :string}
               "pandoc" "-f" "html" "-t" "org")
      :out))

(defn elems [el t]
  (filter #(and (map? %) (= (name (:tag %)) (name t)))
          (:content el)))

(defn text [el]
  (apply str (filter string? (:content el))))

(defn atom-entries [{:keys [url slug]}]
  (let [feed-str (->
                   (babashka.http-client/get url)
                   :body)
        feed (-> feed-str xml/parse-str)]
    (for [entry (elems feed :entry)]
      (let [title (text (first (elems entry :title)))
            link (get-in (first (elems entry :link)) [:attrs :href])
            id (text (first (elems entry :id)))
            date (text (first (elems entry :updated)))
            safe-id (->sha256 (str title link id))]
        {:file (str (->ymd date) "-" slug "-" safe-id ".org")
         :title title
         :link link
         :content (text (first (elems entry :content)))
         :id id
         :date date}))))

(defn rss-items [{:keys [url slug]}]
  (let [feed-str (->
                   (babashka.http-client/get url)
                   :body)
        channel (-> feed-str xml/parse-str (elems :channel) first)]
    (for [item (elems channel :item)]
      (let [title (text (first (elems item :title)))
            link (text (first (elems item :link)))
            id (text (first (elems item :guid)))
            date (text (first (elems item :pubDate)))
            safe-id (->sha256 (str title link id))]
        {:file (str (->ymd date) "-" slug "-" safe-id ".org")
         :title title
         :link link
         :content (text (first (elems item :description)))
         :id id
         :date date}))))

(defn ->org-header [m feed]
  [(str "* " (:title m) "    " (string/join "" (:tags feed)))
   ":PROPERTIES:"
   (str ":ID: " (:id m))
   (str ":FEED: " (:slug feed))
   (str ":LINK: " (:link m))
   (str ":DATE: [" (:date m) "]")
   ":END:"])

(defn feed-entries [feed]
  (if (= (:type feed) :atom)
    (atom-entries feed)
    (rss-items feed)))

(defn drop-page-title [org]
  ;; pandoc emits the page <h1> as the first headline + :CUSTOM_ID: drawer;
  ;; it duplicates our entry headline, so drop it. Sections are already level-2.
  (string/replace-first org #"(?s)\A\*+ [^\n]*\n:PROPERTIES:\n.*?:END:\n" ""))

(defn ->org
  [m feed]
  (let [header (string/join "\n" (->org-header m feed))
        html (if (:fetch-each? feed) 
              (-> (babashka.http-client/get (:link m))
                  :body)
              (:content m))
        org (html->org html)
        org (if (:fetch-each? feed)
              (drop-page-title org)
              org)]
    (str header 
         "\n\n" 
         org)))

(println "Processing feeds")
(doseq [feed (:feeds config)]
  (println (str "Processing feed" feed))
  (let [entries (feed-entries feed)]
    (doseq [e entries]
      (when-not (or (babashka.fs/exists? (str (:feeddir config) "/read/" (:file e)))
                    (babashka.fs/exists? (str (:feeddir config) "/unread/" (:file e)))) 
        (println "Processing new entry" (:id e))
        (spit 
          (str (:feeddir config) "/unread/" (:file e))
          (->org e feed))))))
