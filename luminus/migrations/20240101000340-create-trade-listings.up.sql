CREATE TABLE IF NOT EXISTS trade_listings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  public_id VARCHAR NOT NULL UNIQUE,
  status VARCHAR NOT NULL DEFAULT 'Active',
  listing_type VARCHAR NOT NULL DEFAULT 'FixedPrice',
  asking_price DECIMAL,
  auction_start_price DECIMAL,
  auction_current_bid DECIMAL,
  auction_end_time DATETIME,
  foil BOOLEAN NOT NULL DEFAULT 0,
  condition VARCHAR NOT NULL DEFAULT 'Mint',
  quantity INTEGER NOT NULL DEFAULT 1,
  description TEXT,
  expires_at DATETIME,
  seller_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
  card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
