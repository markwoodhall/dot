(local vabel {})
(local parsers (require "nvim-treesitter.parsers"))
(local util (require :util))

(fn verbatim [results indent lang]
  (util.split 
    (.. 
      "" 
      "\n\n"
      (util.fill-string " " indent) "#+RESULTS:" 
      "\n" 
      (util.fill-string " " indent) "#+begin_example " lang
      "\n" 
      (util.join (icollect [_ v  (ipairs (util.split results "\n"))]
                   (.. (util.fill-string " " indent) v)) "\n") 
      "\n" 
      (util.fill-string " " indent) "#+end_example") 
    "\n"))

(fn presenter [p-type]
  (match p-type
    :verbatim verbatim
    _ verbatim))

(fn command [lang]
  (match lang
    "bash" (fn [env code]
             (let [code (string.gsub (util.join code " ") "^%s*" "")]
               (vim.fn.system 
                 (.. env 
                     " bash -c \"" code "\""))))
    "sql" (fn [env code]
                (let [fname (.. (vim.fn.tempname) ".sql")]
                  (with-open [fout (io.open fname :w)]
                    (fout:write (util.join code "\n")))
                  (vim.fn.system 
                    (.. env 
                        " psql -f " fname))))
    "clojure" (fn [env code]
                (let [fname (.. (vim.fn.tempname) ".clj")]
                  (with-open [fout (io.open fname :w)]
                    (fout:write (util.join code "\n")))
                  (vim.fn.system 
                    (.. env 
                        " bb --file " fname))))
    "fennel" (fn [env code]
               (let [fname (.. (vim.fn.tempname) ".fnl")]
                 (with-open [fout (io.open fname :w)]
                   (fout:write (util.join code "\n")))
                 (vim.fn.system 
                   (.. env 
                       " fennel " fname))))
    "kotlin" (fn [env code]
               (let [fname (.. (vim.fn.tempname) ".kts")]
                 (with-open [fout (io.open fname :w)]
                   (fout:write (util.join code "\n")))
                 (vim.fn.system 
                   (.. env 
                       " kotlinc -script " fname))))))

(fn parse-sql-header [_ header]
  (if header
    (let [parts (util.split header ":")
          kvs (icollect [_ v (ipairs parts)]
                (let [options (util.split v " ")]
                  (match (util.first options)
                    "engine" ""
                    "dbuser" (.. "PGUSER=" (util.last options))
                    "dbpassword" (.. "PGPASSWORD=" (util.last options))
                    "dbhost" (.. "PGHOST=" (util.last options))
                    "dbport" (.. "PGPORT=" (util.last options))
                    "database" (.. "PGDATABASE=" (util.last options)))))]
      (util.build-env
        (util.join kvs "\n")))))

(fn header-parser [lang _header]
  (match lang
    "sql" parse-sql-header
    _ (fn [_ _] "")))

(fn clear-code-block [from-line]
  (let [pos (vim.fn.winsaveview)
        [line1 _] (vim.fn.searchpos "#+begin_example" "c")
        [line2 _] (vim.fn.searchpos "#+end_example$" "c") ]
    (when (and (> line1 0)
               (> line1 from-line))
      (vim.cmd (.. (- line1 1) "," line2 "d")))
    (vim.fn.winrestview pos)))

(fn get-code-block []
  (let [curr-lin (vim.fn.line ".")
        [line1 pos] (vim.fn.searchpos "#+begin_src" "bc")
        [line2 _] (vim.fn.searchpos "#+end_src$" "c")
        code (vim.fn.getline (+ line1 1) (- line2 1))
        line (vim.fn.getline line1)
        lang (util.first (util.split (util.last (util.split line "#+begin_src ")) " "))
        cmd (command lang)]
    (when (and cmd
               (>= curr-lin line1)
               (>= line2 curr-lin))
      (let [headers (util.split line (.. "#+begin_src " lang " "))
            header (util.last headers)
            header-parser-fn (header-parser lang header)
            env (header-parser-fn lang header)]
        {:pos pos
         :lang lang
         :cmd cmd
         :code code
         :start-line line1
         :end-line line2
         :env env}))))

(fn parse-header [header]
  (if header
    (let [parts (util.split header ":")
          kvs (icollect [_ v (ipairs parts)]
                (let [options (util.split v " ")]
                  (match (util.first options)
                    "tangle" (util.last options)
                    "mkdirp" (util.last options))))]
      kvs)))

(set vabel.tangle-blocks 
     (fn []
       (let [parser (parsers.get_parser 0)
             tree (unpack (parser:parse))
             query (vim.treesitter.query.parse 
                     "org"
                     "((block
                        (expr)
                        (expr)
                        (contents)) @block)")]
         (each [_ value (query:iter_captures (tree:root) 0)]
           (local (start-row _ _ _) (value:range))
           (let [header (vim.fn.getline (+ 1 start-row))
                 parsed-header (parse-header header)]
             (when (> (util.count-matches header "begin_src") 0)
               (let [[file _mkdirp] parsed-header]
                 (when file
                   (when (util.exists? (vim.fn.expand file))
                     (print (.. "Deleting tangled file " file))
                     (vim.fn.delete (vim.fn.expand (vim.fn.fnameescape file)))))))))

         (each [_ value (query:iter_captures (tree:root) 0)]
           (local (start-row _ end-row _) (value:range))
           (let [header (vim.fn.getline (+ 1 start-row))
                 source (vim.fn.getline (+ 2 start-row) (- end-row 1))
                 parsed-header (parse-header header)]
             (when (> (util.count-matches header "begin_src") 0)
               (let [[file mkdirp] parsed-header
                     dir (vim.fn.expand (vim.fn.fnamemodify (vim.fn.expand file) ":h"))]
                 (print dir)
                 (when (= mkdirp "yes")
                   (vim.fn.mkdir dir "p"))
                 (when file
                   (print (.. "Tangling code block to file " file))
                   (if (util.exists? (vim.fn.expand file))
                     (vim.fn.writefile source (vim.fn.expand file) "a")
                     (vim.fn.writefile source (vim.fn.expand file)))))))))))

(set vabel.eval-code-block 
     (fn []
       (let [winpos (vim.fn.winsaveview)
             code-block (get-code-block)
             _ (vim.fn.winrestview winpos)]
         (when code-block
           (let [env (. code-block :env)
                 cmd (. code-block :cmd)
                 code (. code-block :code)
                 pos (. code-block :pos)
                 start-line (. code-block :start-line)
                 end-line (. code-block :end-line)
                 presenter (presenter :verbatim)
                 output (presenter (cmd env code) (- pos 1) (. code-block :lang))]
             (clear-code-block start-line)
             (vim.fn.append end-line output))))))

(let [snip (require :luasnip)
      fmt (require "luasnip.extras.fmt")]
  (snip.add_snippets 
    "all"
    [(snip.snippet
      {:trig "vabel-sql" :descr "Create a vabel sql org mode code block"}
      (fmt.fmta
        "#+begin_src sql :dbuser <> :dbpassword <> :dbhost <> :dbpost <> :database <>
<>
#+end_src"
        [(snip.i 1) (snip.i 2) (snip.i 3 "localhost") (snip.i 4 "5432") (snip.i 5) (snip.i 6)]))
     (snip.snippet
       {:trig "vabel-fennel" :descr "Create a vabel fennel org mode code block"}
       (fmt.fmta
         "#+begin_src fennel
<>
#+end_src"
         [(snip.i 1)]))
      (snip.snippet
      {:trig "vabel-clojure" :descr "Create a vabel clojure org mode code block"}
      (fmt.fmta
        "#+begin_src clojure
<>
#+end_src"
        [(snip.i 1)]))
      (snip.snippet
      {:trig "vabel-kotlin" :descr "Create a vabel kotlin org mode code block"}
      (fmt.fmta
        "#+begin_src kotlin
<>
#+end_src"
        [(snip.i 1)]))
      (snip.snippet
      {:trig "vabel-bash" :descr "Create a vabel bash markdown code block"}
      (fmt.fmta
        "#+begin_src bash
<>
#+end_src"
        [(snip.i 1)]))]))

vabel
