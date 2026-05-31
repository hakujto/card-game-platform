(ns cards_project.content.article-service
  (:require [next.jdbc :as jdbc]
            [next.jdbc.result-set :as rs]
            [cards_project.content.article-queries :as queries]
            [cards_project.db :refer [db-spec]]))

(defn validate-article
  "Validate and transform params before persistence."
  [params]
  params)

; ── Domain behavior stubs ──────────────────────────────────────────
(defn- publish-behavior! [id]
  ; TODO: implement publish
  nil)

(defn- archive-behavior! [id]
  ; TODO: implement archive
  nil)

(defn- increment-view-behavior! [id]
  ; TODO: implement increment_view
  nil)

(defn- like-behavior! [id]
  ; TODO: implement like
  nil)

(defn- unlike-behavior! [id]
  ; TODO: implement unlike
  nil)

(defn- reading-time-minutes-behavior! [id]
  ; TODO: implement reading_time_minutes
  nil)

; ── Lifecycle state machine ─────────────────────────────────────────
(def ^:private allowed-transitions
  {   "Draft" ["Published"]
   "Published" ["Archived"]
   "Archived" ["Draft"]})

(defn- assert-transition! [current to]
  (let [allowed (get allowed-transitions current [])]
    (when-not (some #(= % to) allowed)
      (throw (ex-info (str "Transition " current " -> " to " not allowed")
                      {:status 409})))))

(defn transition-draft-to-published!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Published")
      (when (nil? (get record :title))
        (throw (ex-info "title is required for Draft -> Published" {:status 422})))
      (when (nil? (get record :body))
        (throw (ex-info "body is required for Draft -> Published" {:status 422})))
      (jdbc/execute-one! db-spec
        ["UPDATE articles SET status = ? WHERE id = ?" "Published" id])
      (publish-behavior! id) ; @after
      (queries/get-article-by-id db-spec {:id id}))
    (throw (ex-info "Article not found" {:id id :status 404}))))

(defn transition-published-to-archived!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Archived")
      (jdbc/execute-one! db-spec
        ["UPDATE articles SET status = ? WHERE id = ?" "Archived" id])
      (archive-behavior! id) ; @after
      (queries/get-article-by-id db-spec {:id id}))
    (throw (ex-info "Article not found" {:id id :status 404}))))

(defn transition-archived-to-draft!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (do
      (assert-transition! (get record :status) "Draft")
      (jdbc/execute-one! db-spec
        ["UPDATE articles SET status = ? WHERE id = ?" "Draft" id])
      (queries/get-article-by-id db-spec {:id id}))
    (throw (ex-info "Article not found" {:id id :status 404}))))

(defn transition-published-to-draft!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (throw (ex-info "Transition Published -> Draft is not allowed" {:status 409}))
    (throw (ex-info "Article not found" {:id id :status 404}))))

(defn publish!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (publish-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn archive!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (archive-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn increment-view!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (increment-view-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn like!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (like-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn unlike!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (unlike-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

(defn reading-time-minutes!
  [id]
  (if-let [record (queries/get-article-by-id db-spec {:id id})]
    (reading-time-minutes-behavior! id)
    (throw (ex-info "Article not found" {:id id}))))

; ── Lifecycle hooks ─────────────────────────────────────────────────
(defn- update-search-index-hook! [record]
  ; TODO: implement update_search_index
  record)

