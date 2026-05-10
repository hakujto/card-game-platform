-- :name get-all-article-tag :? :*
-- :doc Get all Article Tag records
SELECT id, name, slug, created_at, updated_at FROM article_tags

-- :name get-article-tag-by-id :? :1
-- :doc Get a single Article Tag by id
SELECT id, name, slug, created_at, updated_at FROM article_tags WHERE id = :id

-- :name delete-article-tag! :! :n
-- :doc Delete a Article Tag by id
DELETE FROM article_tags WHERE id = :id
