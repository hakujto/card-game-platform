# Migration: create_products
module Migrations
  def self.create_products(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        product_type VARCHAR(255) NOT NULL DEFAULT "SingleCard",
        price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        active BOOLEAN NOT NULL DEFAULT true,
        discount_percent INTEGER NOT NULL DEFAULT 0,
        description TEXT,
        image_url VARCHAR(500),
        featured BOOLEAN NOT NULL DEFAULT false,
        card_id INTEGER UNIQUE REFERENCES cards(id) ON DELETE SET NULL,
        card_set_id INTEGER REFERENCES card_sets(id) ON DELETE SET NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_orders
module Migrations
  def self.create_orders(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status VARCHAR(255) NOT NULL DEFAULT "Pending",
        total REAL NOT NULL DEFAULT 0.0,
        discount_applied REAL NOT NULL DEFAULT 0.0,
        currency VARCHAR(255) NOT NULL DEFAULT "USD",
        payment_method VARCHAR(255),
        payment_reference VARCHAR(255),
        shipping_address TEXT,
        tracking_number VARCHAR(255),
        paid_at DATETIME,
        shipped_at DATETIME,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        coupon_id INTEGER REFERENCES coupons(id) ON DELETE SET NULL,
        created_by INTEGER,
        updated_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_order_items
module Migrations
  def self.create_order_items(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity INTEGER NOT NULL,
        price_at_purchase REAL NOT NULL,
        foil BOOLEAN NOT NULL DEFAULT false,
        order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
        product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_coupons
module Migrations
  def self.create_coupons(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS coupons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code VARCHAR(255) NOT NULL UNIQUE,
        discount_type VARCHAR(255) NOT NULL DEFAULT "Percent",
        discount_value REAL NOT NULL,
        min_order_value REAL NOT NULL DEFAULT 0.0,
        max_uses INTEGER,
        uses_count INTEGER NOT NULL DEFAULT 0,
        valid_from DATETIME NOT NULL,
        valid_until DATETIME NOT NULL,
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_trade_listings
module Migrations
  def self.create_trade_listings(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS trade_listings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        public_id VARCHAR(36) NOT NULL UNIQUE,
        status VARCHAR(255) NOT NULL DEFAULT "Active",
        listing_type VARCHAR(255) NOT NULL DEFAULT "FixedPrice",
        asking_price REAL,
        auction_start_price REAL,
        auction_current_bid REAL,
        auction_end_time DATETIME,
        foil BOOLEAN NOT NULL DEFAULT false,
        condition VARCHAR(255) NOT NULL DEFAULT "Mint",
        quantity INTEGER NOT NULL DEFAULT 1,
        description TEXT,
        expires_at DATETIME,
        seller_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_trade_bids
module Migrations
  def self.create_trade_bids(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS trade_bids (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        placed_at DATETIME NOT NULL,
        is_winning BOOLEAN NOT NULL DEFAULT false,
        listing_id INTEGER NOT NULL REFERENCES trade_listings(id) ON DELETE CASCADE,
        bidder_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_trade_transactions
module Migrations
  def self.create_trade_transactions(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS trade_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        final_price REAL NOT NULL,
        platform_fee REAL NOT NULL,
        status VARCHAR(255) NOT NULL DEFAULT "Pending",
        completed_at DATETIME,
        listing_id INTEGER NOT NULL UNIQUE REFERENCES trade_listings(id) ON DELETE RESTRICT,
        buyer_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        seller_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_by INTEGER,
        updated_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_card_price_histories
module Migrations
  def self.create_card_price_histories(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS card_price_histories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        price_date DATE NOT NULL,
        avg_price REAL NOT NULL,
        min_price REAL NOT NULL,
        max_price REAL NOT NULL,
        volume INTEGER NOT NULL,
        foil BOOLEAN NOT NULL DEFAULT false,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_trade_disputes
module Migrations
  def self.create_trade_disputes(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS trade_disputes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status VARCHAR(255) NOT NULL DEFAULT "Open",
        reason VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        resolution TEXT,
        opened_at DATETIME NOT NULL,
        resolved_at DATETIME,
        transaction_id INTEGER NOT NULL UNIQUE REFERENCES trade_transactions(id) ON DELETE CASCADE,
        opened_by_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        resolved_by_id INTEGER REFERENCES players(id) ON DELETE SET NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end
