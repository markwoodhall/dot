(local npm {})

(set npm.setup 
     (fn []))

(fn completion [_ c]
  (vim.fn.sort
    (let [util (require :util)
          c-parts (util.split c " ")]
      (match (util.count-matches c "%s")
        0 []
        1 (accumulate 
            [results []
             _ v (ipairs [:access :adduser :audit :bugs :cache :ci :completion
                          :config :dedupe :deprecate :diff :dist-tag :docs :doctor
                          :edit :exec :explain :explore :find-dupes :fund :get :help
                          :help-search :hook :init :install :install-ci-test
                          :install-test :link :ll :login :logout :ls :org :outdated
                          :owner :pack :ping :pkg :prefix :profile :prune :publish
                          :query :rebuild :repo :restart :root :run :run-script :search
                          :set :shrinkwrap :star :stars :start :stop :team :test
                          :token :uninstall :unpublish :unstar :update :version :view
                          :whoami])]
            (util.add-match v (util.second c-parts) results))
        2 (if (= (util.second c-parts) "run")
            (let [runs (vim.fn.system "jq '.scripts|keys[]' package.json | sed 's/\\\"//g'")]
              (util.split runs "\n"))
            [])))))

(vim.api.nvim_create_user_command
  "Npm"
  (fn [opts]
    (let [util (require :util)
          args (util.gather-args opts)]
      (util.pane-terminal-command (.. "npm " args))))
  {:bang false :desc "NPM wrapper" :nargs "*"
   :complete completion})

npm
