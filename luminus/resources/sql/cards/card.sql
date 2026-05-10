-- :name get-all-card :? :*
-- :doc Get all Card records
SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id, created_at, updated_at FROM cards

-- :name get-card-by-id :? :1
-- :doc Get a single Card by id
SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id, created_at, updated_at FROM cards WHERE id = :id

-- :name delete-card! :! :n
-- :doc Delete a Card by id
DELETE FROM cards WHERE id = :id
