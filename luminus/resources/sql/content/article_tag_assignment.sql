-- :name get-all-article-tag-assignment :? :*
-- :doc Get all Article Tag Assignment records
SELECT id, article_id, tag_id, created_at, updated_at FROM article_tag_assignments

-- :name get-article-tag-assignment-by-id :? :1
-- :doc Get a single Article Tag Assignment by id
SELECT id, article_id, tag_id, created_at, updated_at FROM article_tag_assignments WHERE id = :id

-- :name delete-article-tag-assignment! :! :n
-- :doc Delete a Article Tag Assignment by id
DELETE FROM article_tag_assignments WHERE id = :id
