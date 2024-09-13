(local docker {})

(set docker.setup 
     (fn []))

(fn containers []
  (let [util (require :util)
        containers (vim.fn.system "docker ps --format \"{{json .}}\" | jq .Names    | sed 's/\\\"//g'")]
    (util.split containers "\n")))

(fn completion [_ c]
  (vim.fn.sort
    (let [util (require :util)
          c-parts (util.split c " ")
          with-defaults (fn [c] ["--format" (unpack c)])]
      (match (util.count-matches c "%s")
        0 []
        1 (accumulate 
            [results []
             _ v (ipairs [:run :exec :ps :build :pull :push :images :login
                          :logout :search :version :info :builder :compose :container
                          :context :image :manifest :network :plugin :system :trust
                          :volume :swarm :attach :commit :cp :create :diff :events :export
                          :history :import :inspect :kill :load :logs :pause :port :rename
                          :restart :rm :rmi :save :start :stats :stop :tag :top 
                          :unpause :update :wait])]
            (util.add-match v (util.second c-parts) results))
        2 (match (util.second c-parts)
            "logs" (with-defaults (containers))
            "kill" (with-defaults (containers))
            "compose" (with-defaults [:up :down])
            "volume" (with-defaults [:create :inspect :prune :ls :rm])
            _ (with-defaults []))
        3 (match (util.nth c-parts 3)
            "up" ["--detach"])))))

(vim.api.nvim_create_user_command
  "Docker"
  (fn [opts]
    (let [util (require :util)
          args (util.gather-args opts)]
      (util.pane-terminal-command (.. "docker " args))))
  {:bang false :desc "Docker wrapper" :nargs "*"
   :complete completion})

docker
