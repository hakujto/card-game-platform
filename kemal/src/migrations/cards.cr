# Migration: create_cards
module Migrations
  def self.create_cards(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        public_id VARCHAR(36) NOT NULL UNIQUE,
        name VARCHAR(255) NOT NULL,
        card_type VARCHAR(255) NOT NULL DEFAULT "Creature",
        rarity VARCHAR(255) NOT NULL DEFAULT "Common",
        mana_cost INTEGER NOT NULL DEFAULT 0,
        mana_colors VARCHAR(255) NOT NULL,
        attack INTEGER,
        defense INTEGER,
        loyalty INTEGER,
        description TEXT NOT NULL,
        flavor_text TEXT,
        image_url VARCHAR(500),
        artist_name VARCHAR(255),
        legal_formats VARCHAR(255) NOT NULL,
        is_banned BOOLEAN NOT NULL DEFAULT false,
        is_restricted BOOLEAN NOT NULL DEFAULT false,
        power_level INTEGER NOT NULL DEFAULT 1,
        metadata TEXT,
        total_copies_in_circulation BIGINT NOT NULL DEFAULT 0,
        set_id INTEGER NOT NULL REFERENCES card_sets(id) ON DELETE RESTRICT,
        created_by INTEGER,
        updated_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_card_sets
module Migrations
  def self.create_card_sets(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS card_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        code VARCHAR(255) NOT NULL UNIQUE,
        release_date DATE NOT NULL,
        rotation_date DATE,
        set_type VARCHAR(255) NOT NULL DEFAULT "Expansion",
        total_cards INTEGER NOT NULL,
        is_rotated BOOLEAN NOT NULL DEFAULT false,
        description TEXT,
        logo_url VARCHAR(500),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_card_rulings
module Migrations
  def self.create_card_rulings(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS card_rulings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ruling_text TEXT NOT NULL,
        published_at DATE NOT NULL,
        source VARCHAR(255) NOT NULL,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_card_abilities
module Migrations
  def self.create_card_abilities(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS card_abilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ability_type VARCHAR(255) NOT NULL DEFAULT "Keyword",
        keyword VARCHAR(255),
        ability_text TEXT NOT NULL,
        timing VARCHAR(255),
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_decks
module Migrations
  def self.create_decks(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        format VARCHAR(255) NOT NULL DEFAULT "Standard",
        is_public BOOLEAN NOT NULL DEFAULT false,
        is_tournament_legal BOOLEAN NOT NULL DEFAULT false,
        archetype VARCHAR(255),
        wins INTEGER NOT NULL DEFAULT 0,
        losses INTEGER NOT NULL DEFAULT 0,
        draws INTEGER NOT NULL DEFAULT 0,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_deck_cards
module Migrations
  def self.create_deck_cards(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS deck_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity INTEGER NOT NULL DEFAULT 1,
        is_commander BOOLEAN NOT NULL DEFAULT false,
        deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_deck_sideboard_cards
module Migrations
  def self.create_deck_sideboard_cards(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS deck_sideboard_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity INTEGER NOT NULL DEFAULT 1,
        deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_deck_tags
module Migrations
  def self.create_deck_tags(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS deck_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        slug VARCHAR(255),
        color VARCHAR(255),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_deck_tag_assignments
module Migrations
  def self.create_deck_tag_assignments(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS deck_tag_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
        tag_id INTEGER NOT NULL REFERENCES deck_tags(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end
