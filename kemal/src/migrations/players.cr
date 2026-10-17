# Migration: create_players
module Migrations
  def self.create_players(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        public_id VARCHAR(36) NOT NULL UNIQUE,
        display_name VARCHAR(255) NOT NULL UNIQUE,
        rank VARCHAR(255) NOT NULL DEFAULT "Bronze",
        rating INTEGER NOT NULL DEFAULT 1000,
        peak_rating INTEGER NOT NULL DEFAULT 1000,
        bio TEXT,
        country_code VARCHAR(255),
        avatar_url VARCHAR(500),
        preferred_format VARCHAR(255),
        contact_email VARCHAR(255),
        win_rate_cached REAL,
        is_verified BOOLEAN NOT NULL DEFAULT false,
        last_active_at DATETIME,
        user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_player_season_statses
module Migrations
  def self.create_player_season_statses(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS player_season_statses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wins INTEGER NOT NULL DEFAULT 0,
        losses INTEGER NOT NULL DEFAULT 0,
        draws INTEGER NOT NULL DEFAULT 0,
        tournament_wins INTEGER NOT NULL DEFAULT 0,
        highest_rank VARCHAR(255),
        season_points INTEGER NOT NULL DEFAULT 0,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_player_collections
module Migrations
  def self.create_player_collections(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS player_collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity INTEGER NOT NULL DEFAULT 1,
        foil BOOLEAN NOT NULL DEFAULT false,
        condition VARCHAR(255) NOT NULL DEFAULT "Mint",
        acquired_at DATETIME NOT NULL,
        acquired_via VARCHAR(255) NOT NULL DEFAULT "Purchase",
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_friendships
module Migrations
  def self.create_friendships(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS friendships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status VARCHAR(255) NOT NULL DEFAULT "Pending",
        requester_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        receiver_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_achievements
module Migrations
  def self.create_achievements(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        icon_url VARCHAR(500),
        points INTEGER NOT NULL DEFAULT 10,
        rarity VARCHAR(255) NOT NULL DEFAULT "Common",
        is_hidden BOOLEAN NOT NULL DEFAULT false,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_player_achievements
module Migrations
  def self.create_player_achievements(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS player_achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        earned_at DATETIME NOT NULL,
        progress INTEGER NOT NULL DEFAULT 0,
        is_completed BOOLEAN NOT NULL DEFAULT false,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        achievement_id INTEGER NOT NULL REFERENCES achievements(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_crafting_recipes
module Migrations
  def self.create_crafting_recipes(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS crafting_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dust_cost INTEGER NOT NULL,
        is_available BOOLEAN NOT NULL DEFAULT true,
        result_card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_crafting_ingredients
module Migrations
  def self.create_crafting_ingredients(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS crafting_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quantity INTEGER NOT NULL DEFAULT 1,
        recipe_id INTEGER NOT NULL REFERENCES crafting_recipes(id) ON DELETE CASCADE,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end
