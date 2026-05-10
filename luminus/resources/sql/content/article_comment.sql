-- :name get-all-article-comment :? :*
-- :doc Get all Article Comment records
SELECT id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at FROM article_comments

-- :name get-article-comment-by-id :? :1
-- :doc Get a single Article Comment by id
SELECT id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at FROM article_comments WHERE id = :id

-- :name delete-article-comment! :! :n
-- :doc Delete a Article Comment by id
DELETE FROM article_comments WHERE id = :id
