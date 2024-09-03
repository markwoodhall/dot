(local npm {})
(local util (require :util))

(set npm.setup 
     (fn []))

(fn completion [_ c]
  (vim.fn.sort
    (let [c-parts (util.split c " ")]
      (match (util.count-matches c "%s")
        0 []
        1 (if (< (util.count-matches c "%s") 2)
            (accumulate 
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
              (if (or (and (util.second c-parts) 
                           (> (util.count-matches v (util.second c-parts)) 0))
                      (not (util.second c-parts)))
                [v (unpack results)]
                results)))
        2 (if (= (util.second c-parts) "run")
            (let [runs (vim.fn.system "jq '.scripts|keys[]' package.json | sed 's/\\\"//g'")]
              (util.split runs "\n"))
            [(util.second c-parts)])))))

(vim.api.nvim_create_user_command
  "Npm"
  (fn [opts]
    (let [args (accumulate 
          [s ""
           _ v (ipairs (?. opts :fargs))]
          (.. s " " v))]
      (util.pane-terminal-command (.. "npm " args))))
  {:bang false :desc "NPM wrapper" :nargs "*"
   :complete completion})

npm
