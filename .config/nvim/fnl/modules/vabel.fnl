(local vabel {})
(local parsers (require "nvim-treesitter.parsers"))
(local util (require :util))

(fn verbatim [results indent lang]
  (match lang
    "sql" (let [t (util.split results "\n")
                t (icollect [_ v  (ipairs t)]
                    (.. (util.fill-string " " indent) (if (not= v "") (.. "|" v "|") v)))] 
            (table.insert t 1 (.. (util.fill-string " " indent) (.. "#+BEGIN_EXAMPLE " lang)))
            (table.insert t 1 (.. (util.fill-string " " indent) "#+RESULTS:"))
            (table.insert t 1 "")
            (table.insert t (.. (util.fill-string " " indent) "#+END_EXAMPLE"))
            t)
    _ (let [t (util.split results "\n")
                t (icollect [_ v  (ipairs t)]
                    (.. (util.fill-string " " indent) v))] 
            (table.insert t 1 (.. (util.fill-string " " indent) (.. "#+BEGIN_EXAMPLE " lang)))
            (table.insert t 1 (.. (util.fill-string " " indent) "#+RESULTS:"))
            (table.insert t 1 "")
            (table.insert t (.. (util.fill-string " " indent) "#+END_EXAMPLE"))
            t)))

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
                    (fout:write (.. "\\timing off\n" (util.join code "\n"))))
                  (vim.fn.system 
                    (.. env 
                        " psql -P footer=off -q -f " fname))))
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
        [line1 _] (vim.fn.searchpos "\\c#+BEGIN_EXAMPLE" "c")
        [line2 _] (vim.fn.searchpos "\\c#+END_EXAMPLE" "c") ]
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
          kvs (accumulate [h {:tangle nil :shebang nil :mkdirp nil} _ v (ipairs parts)]
                (let [options (util.split v " ")]
                  (match (util.first options)
                    "shebang" (set h.shebang (util.last options))
                    "tangle" (set h.tangle (util.last options))
                    "mkdirp" (set h.mkdirp (util.last options)))
                  h))]
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
               (let [file (. parsed-header :tangle)]
                 (when file
                   (when (util.exists? (vim.fn.expand file))
                     (print (.. "Clearing tangled file " file))
                     (vim.fn.writefile [] (vim.fn.expand (vim.fn.fnameescape file)))))))))

         (var count 0)
         (each [_ value (query:iter_captures (tree:root) 0)]
           (local (start-row _ end-row _) (value:range))
           (let [header (vim.fn.getline (+ 1 start-row))
                 source (vim.fn.getline (+ 2 start-row) (- end-row 1))
                 parsed-header (parse-header header)]
             (when (> (util.count-matches header "begin_src") 0)
               (let [file (. parsed-header :tangle)
                     mkdirp (. parsed-header :mkdirp)
                     shebang (. parsed-header :shebang)
                     dir (vim.fn.expand (vim.fn.fnamemodify (vim.fn.expand file) ":h"))]
                 (when (= mkdirp "yes")
                 (print "making")
                   (vim.fn.mkdir dir "p"))
                 (when file
                   (print (.. "Tangling code block to file " file))
                   (when shebang 
                     (print "shebang")
                     (print shebang)
                     (if (util.exists? (vim.fn.expand file))
                       (vim.fn.writefile [shebang] (vim.fn.expand file) "a")
                       (vim.fn.writefile [shebang] (vim.fn.expand file))))
                   (if (util.exists? (vim.fn.expand file))
                     (vim.fn.writefile source (vim.fn.expand file) "a")
                     (vim.fn.writefile source (vim.fn.expand file)))))))
           (set count (+ 1 count))))))

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
