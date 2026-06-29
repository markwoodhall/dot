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

(defn sitemap-entries [{:keys [url slug sitemap-query non-parseable-date?]}]
  (let [sitemap-xml (->
                     (babashka.http-client/get url)
                     :body)
        entries (->> (xml/parse-str sitemap-xml)
       (#(elems % :url))
       (keep (fn [url]
               (let [loc (text (first (elems url :loc)))]
                 (when (and loc (re-find (re-pattern sitemap-query) loc))
                   {:loc loc
                    :lastmod (text (first (elems url :lastmod)))}))))
       (sort-by :loc))]
    (for [item entries]
      (let [title (:loc item)
            link (:loc item)
            id (:loc item)
            date (:lastmod item)
            safe-id (->sha256 (str title link id))
            date (if non-parseable-date?
                   date
                   (->ymd date))]
        {:file (str date "-" slug "-" safe-id ".org")
         :title title
         :link link
         :id id
         :date date}))))

(defn ->org-header [m feed]
  [(if-not (-> feed :org-header :no-title?) 
     (str "* " (:title m) "    " (string/join "" (:tags feed)))
     "")
   ":PROPERTIES:"
   (str ":ID: " (:id m))
   (str ":FEED: " (:slug feed))
   (str ":LINK: " (:link m))
   (str ":DATE: [" (:date m) "]")
   ":END:"])

(defn feed-entries [feed]
  (case (:type feed)
    :atom (atom-entries feed)
    :rss (rss-items feed)
    :sitemap (sitemap-entries feed)
    (atom-entries feed)))

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

(defn mkdirp [dir]
  (str "mkdir -p " dir))

(defn path [dir f]
  (let [dir (str (:feeddir config) "/" dir "/")
        path (str  dir (when f f))]
    (babashka.process/shell
      {:out :string}
      (mkdirp dir))
    path))

(defn unread-path [f]
  (path "unread" f))

(defn read-path [f]
  (path "read" f))

(println "Processing feeds")
(doseq [feed (:feeds config)]
  (println (str "Processing feed" feed))
  (let [entries (feed-entries feed)]
    (doseq [e entries]
      (if (:dir feed)
        (when-not (babashka.fs/exists? (path (:dir feed) (:file e)))
          (println "Processing new entry" (:id e))
          (spit
            (path (:dir feed) (:file e))
            "")
          (spit
            (path (:dir feed) (str (:slug feed) ".org"))
            (->org e feed)
            :append true)
          (spit
            (path (:dir feed) (str (:dir feed) ".org"))
            (->org e feed)
            :append true))
        (when-not (or (babashka.fs/exists? (read-path (:file e)))
                      (babashka.fs/exists? (unread-path (:file e))))
          (println "Processing new entry" (:id e))
          (spit
            (unread-path (:file e))
            (->org e feed)))))))
