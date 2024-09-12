;;bw list items --session $(cat ~/.bwsession) | jq '.[].name'
(local bw {})
(local util (require :util))

(set bw.setup 
     (fn []))

(fn items []
  (let [items (vim.fn.system "bw list items --session `cat ~/.bwsession` | jq '.[].name' | sed 's/\\\"//g'")]
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
            (util.add-match v (util.second c-parts 3) results))
        2 (match (util.nth c-parts 2)
            "get" (accumulate 
                    [results []
                     _ v (ipairs [:password :item])]
                    (util.add-match v (util.nth c-parts 3) results))
            "list" (accumulate 
                      [results []
                       _ v (ipairs [:items])]
                      (util.add-match v (util.nth c-parts 3) results))
            _ (with-defaults []))
        3 (match (util.nth c-parts 3)
            "password" (with-defaults (items))
            "item" (with-defaults (items))
            _ (with-defaults []))
        _ (with-defaults [])))))

(vim.api.nvim_create_user_command
  "Bw"
  (fn [opts]
    (let [args (util.gather-args opts)]
      (vim.cmd (.. "!bw " args))))
  {:bang false :desc "BW wrapper" :nargs "*"
   :complete completion})

bw
