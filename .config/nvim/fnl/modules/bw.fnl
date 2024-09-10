;;bw list items --session $(cat ~/.bwsession) | jq '.[].name'
(local bw {})
(local util (require :util))

(set bw.setup 
     (fn []))

(fn items []
  (let [items (vim.fn.system "bw list items --session $(cat ~/.bwsession) | jq '.[].name' | sed 's/\\\"//g'")]
    (util.split items "\n")))

(fn completion [_ c]
  (vim.fn.sort
    (let [c-parts (util.split c " ")
          with-defaults (fn [c] ["--session $(cat ~/.bwsession)" (unpack c)])]
      (match (util.count-matches c "%s")
        0 []
        1 (accumulate 
            [results []
             _ v (ipairs [:list :get])]
            (if (or (and (util.second c-parts) 
                         (> (util.count-matches v (util.second c-parts)) 0))
                    (not (util.second c-parts)))
              [v (unpack results)]
              results))
        2 (match (util.nth c-parts 2)
            "get" (accumulate 
                    [results []
                     _ v (ipairs [:password])]
                    (if (or (and (util.nth c-parts 3) 
                                 (> (util.count-matches v (util.nth c-parts 3)) 0))
                            (not (util.nth c-parts 3)))
                      [v (unpack results)]
                      results))
            "list" (accumulate 
                      [results []
                       _ v (ipairs [:items])]
                      (if (or (and (util.nth c-parts 3) 
                                   (> (util.count-matches v (util.nth c-parts 3)) 0))
                              (not (util.nth c-parts 3)))
                        [v (unpack results)]
                        results))
            _ (with-defaults []))
        3 (match (util.nth c-parts 3)
            "password" (with-defaults (items))
            _ (with-defaults []))
        _ (with-defaults [])))))

(vim.api.nvim_create_user_command
  "Bw"
  (fn [opts]
    (let [args (accumulate 
                 [s ""
                  _ v (ipairs (?. opts :fargs))]
                 (.. s " " v))]
      (util.pane-terminal-command (.. "bw " args))))
  {:bang false :desc "BW wrapper" :nargs "*"
   :complete completion})

bw
