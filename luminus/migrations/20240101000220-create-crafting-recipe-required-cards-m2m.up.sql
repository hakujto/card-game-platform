CREATE TABLE IF NOT EXISTS crafting_recipes_required_cards_m2m (
  left_id INTEGER NOT NULL REFERENCES crafting_recipes(id) ON DELETE CASCADE,
  right_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  PRIMARY KEY (left_id, right_id)
);
