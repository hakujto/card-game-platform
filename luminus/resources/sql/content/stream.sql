-- :name get-all-stream :? :*
-- :doc Get all Stream records
SELECT id, title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams

-- :name get-stream-by-id :? :1
-- :doc Get a single Stream by id
SELECT id, title, stream_url, platform, status, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams WHERE id = :id

-- :name delete-stream! :! :n
-- :doc Delete a Stream by id
DELETE FROM streams WHERE id = :id
