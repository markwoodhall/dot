(local util (require :util))
(local parsers (require "nvim-treesitter.parsers"))
(local codelens {})

(var namespace (vim.api.nvim_create_namespace "codelens"))

(fn relative-to-seconds [unit val]
  (match unit
    "years" (* (tonumber val) 365 24 60 60)
    "year" (* (tonumber val) 365 24 60 60)
    "months" (* (tonumber val) 30 24 60 60)
    "month" (* (tonumber val) 30 24 60 60)
    "weeks" (* (tonumber val) 7 24 60 60)
    "week" (* (tonumber val) 7 24 60 60)
    "day" (* (tonumber val) 24 60 60)
    "days" (* (tonumber val) 24 60 60)
    "hours" (* (tonumber val) 60 60)
    "hour" (* (tonumber val) 60 60)
    "minute" (* (tonumber val) 60)
    "minutes" (* (tonumber val) 60)
    "second" (tonumber val)
    "seconds" (tonumber val)))

(fn most-recent [c separator]
  (var recent "")
  (var last-score (* 100 365 24 60 60))
  (each [_ v (ipairs c)]
    (let [author (util.first v) 
          date (util.second v)
          parts (util.split date ",")
          score (accumulate [sc 0 _ p (ipairs parts)]
                  (let [number (util.first (util.split p " "))
                        unit (util.second (util.split p ""))]
                    (+ sc (relative-to-seconds unit number))))]
      (when (< score last-score)
        (set last-score score)
        (set recent (.. author separator (util.join (util.but-last (util.split date " ")) " "))))))
  recent)

(fn authors [data]
  (let [author-list (util.split data "Author:")]
    (icollect [_ v (ipairs author-list)]
      (let [a (util.split v " Date: ")]
        (util.first a)))))

(fn author-dates [data]
  (let [author-list (util.split data "Author:")]
    (icollect [_ v (ipairs author-list)]
      (let [a (util.split v " Date: ")]
        a))))

(fn process-blame-block [start-line job-id data event line-offset]
  (let [d (util.join data " ")
        authors (util.distinct (authors d))
        author-dates (author-dates d)
        separator (if (> (length authors) 1) (.." and " (- (length authors) 1) " others ") " ")
        latest (most-recent author-dates separator)
        message latest]
    (if (not (util.empty authors))
      (vim.api.nvim_buf_set_extmark
        (vim.api.nvim_get_current_buf)
        namespace
        (- (tonumber start-line) line-offset)
        0
        {:id job-id :virt_text_pos "eol" :virt_text [[message "CodeLensReference"]]}))))

(fn git-blame-block [file start-line end-line line-offset]
  (let [line (if (= start-line "0") "1" start-line)
        offset (if (= start-line "0") (+ line-offset 1) line-offset)]
    (vim.fn.jobstart 
      ["bash" "-c"
       (.. 
         "blame " file " " line " " end-line)]
      {:on_stderr (fn [_job-id data _event] (print (util.join data " ")))
       :on_stdout (fn [job-id data event]
                    (process-blame-block
                      line
                      job-id
                      data
                      event
                      offset))})))

(set codelens.get-blocks (fn [filetype ts-query]
  (vim.api.nvim_buf_clear_highlight
    (vim.api.nvim_get_current_buf)
    namespace
    0
    -1)
  (if ts-query
    (let [parser (parsers.get_parser 0)
          tree (unpack (parser:parse))
          query (vim.treesitter.query.parse 
                  filetype
                  ts-query)]
      (each [_ value (query:iter_captures (tree:root) 0)]
        (let [start (value:start)
              end (value:end_)
              s-parts (util.split start " ")
              e-parts (util.split end " ")
              line1 (util.first s-parts)
              line2 (util.first e-parts)] 
          (git-blame-block (vim.fn.expand "%:p") line1 line2 0))))
    (git-blame-block (vim.fn.expand "%:p") 1 (vim.fn.line "$") 1))))

codelens
