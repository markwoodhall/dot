(local core (require "aniseed.core"))
(local util (require :util))

;; Load all modules in no particular order.
(->> (util.glob (.. util.config-path "/lua/modules/*.lua"))
     (core.run! (fn [path]
                  (require (string.gsub path ".*/(.-)/(.-)%.lua" "%1.%2")))))
