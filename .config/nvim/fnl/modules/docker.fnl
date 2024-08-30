(local docker {})
(local util (require :util))

(set docker.setup 
     (fn []))

(fn containers []
  (let [containers (vim.fn.system "docker ps --format \"{{json .}}\" | jq .Names    | sed 's/\\\"//g'")]
    (util.split containers "\n")))

(fn completion [_ c]
  (let [c-parts (util.split c " ")
        with-defaults (fn [c] ["--format" (unpack c)])]
    (match (util.count-matches c "%s")
      0 []
      1 (if (< (util.count-matches c "%s") 2)
        (accumulate 
          [results []
           _ v (ipairs [:run :exec :ps :build :pull :push :images :login
                        :logout :search :version :info :builder :compose :container
                        :context :image :manifest :network :plugin :system :trust
                        :volume :swarm :attach :commit :cp :create :diff :events :export
                        :history :import :inspect :kill :load :logs :pause :port :rename
                        :restart :rm :rmi :save :start :stats :stop :tag :top 
                        :unpause :update :wait])]
          (if (or (and (util.second c-parts) 
                       (> (util.count-matches v (util.second c-parts)) 0))
                  (not (util.second c-parts)))
            [v (unpack results)]
            results)))
      2 (match (util.second c-parts)
          "logs" (with-defaults (containers))
          "kill" (with-defaults (containers))
          "compose" (with-defaults [:up :down])
          "volume" (with-defaults [:create :inspect :prune :ls :rm])
          _ (with-defaults []))
      3 (match (util.nth c-parts 3)
          "up" ["--detach"]))))

(vim.api.nvim_create_user_command
  "Docker"
  (fn [opts]
    (let [args (accumulate 
                 [s ""
                  _ v (ipairs (?. opts :fargs))]
                 (.. s " " v))]
      (util.pane-terminal-command (.. "docker " args))))
  {:bang false :desc "Docker wrapper" :nargs "*"
   :complete completion})

docker
