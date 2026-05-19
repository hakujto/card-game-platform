-- :name get-all-article :? :*
-- :doc Get all Article records
SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles

-- :name get-article-by-id :? :1
-- :doc Get a single Article by id
SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles WHERE id = :id

-- :name delete-article! :! :n
-- :doc Delete a Article by id
DELETE FROM articles WHERE id = :id
