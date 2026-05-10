(ns build
  (:require [clojure.tools.build.api :as b]))

(def basis (delay (b/create-basis {:project "deps.edn"})))
(def uber-file (str "target/cards-project-standalone.jar"))

(defn uber [_]
  (b/copy-dir {:src-dirs ["src" "resources"] :target-dir "target/classes"})
  (b/compile-clj {:basis @basis :src-dirs ["src"] :class-dir "target/classes"})
  (b/uber {:class-dir "target/classes" :uber-file uber-file :basis @basis :main 'cards-project.core}))
