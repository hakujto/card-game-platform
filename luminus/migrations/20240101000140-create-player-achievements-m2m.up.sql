CREATE TABLE IF NOT EXISTS players_achievements_m2m (
  left_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  right_id INTEGER NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  PRIMARY KEY (left_id, right_id)
);
