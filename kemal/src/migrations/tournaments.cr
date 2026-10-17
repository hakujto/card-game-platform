# Migration: create_seasons
module Migrations
  def self.create_seasons(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS seasons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        format VARCHAR(255) NOT NULL DEFAULT "Standard",
        is_active BOOLEAN NOT NULL DEFAULT false,
        reward_description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_tournaments
module Migrations
  def self.create_tournaments(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS tournaments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        public_id VARCHAR(36) NOT NULL UNIQUE,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        status VARCHAR(255) NOT NULL DEFAULT "Draft",
        bracket_data TEXT,
        format VARCHAR(255) NOT NULL DEFAULT "Standard",
        tournament_type VARCHAR(255) NOT NULL DEFAULT "Swiss",
        max_players INTEGER NOT NULL,
        entry_fee REAL NOT NULL DEFAULT 0.0,
        prize_pool REAL NOT NULL DEFAULT 0.0,
        start_time DATETIME NOT NULL,
        end_time DATETIME,
        is_online BOOLEAN NOT NULL DEFAULT true,
        location VARCHAR(255),
        rules_text TEXT,
        season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE RESTRICT,
        organizer_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_by INTEGER,
        updated_by INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_tournament_judges
module Migrations
  def self.create_tournament_judges(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS tournament_judges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role VARCHAR(255) NOT NULL DEFAULT "Judge",
        tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_tournament_registrations
module Migrations
  def self.create_tournament_registrations(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS tournament_registrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status VARCHAR(255) NOT NULL DEFAULT "Registered",
        seed INTEGER,
        final_standing INTEGER,
        points_earned INTEGER NOT NULL DEFAULT 0,
        registered_at DATETIME NOT NULL,
        tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_tournament_rounds
module Migrations
  def self.create_tournament_rounds(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS tournament_rounds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        round_number INTEGER NOT NULL,
        status VARCHAR(255) NOT NULL DEFAULT "Pending",
        started_at DATETIME,
        ended_at DATETIME,
        time_limit_minutes INTEGER NOT NULL DEFAULT 50,
        tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_matches
module Migrations
  def self.create_matches(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER,
        status VARCHAR(255) NOT NULL DEFAULT "Pending",
        player1_wins INTEGER NOT NULL DEFAULT 0,
        player2_wins INTEGER NOT NULL DEFAULT 0,
        started_at DATETIME,
        ended_at DATETIME,
        result_notes TEXT,
        round_id INTEGER NOT NULL REFERENCES tournament_rounds(id) ON DELETE CASCADE,
        player1_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        player2_id INTEGER REFERENCES players(id) ON DELETE SET NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_games
module Migrations
  def self.create_games(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_number INTEGER NOT NULL,
        winner_side VARCHAR(255),
        complexity_score REAL,
        turns_played INTEGER,
        duration_seconds INTEGER,
        ended_by VARCHAR(255),
        replay_url VARCHAR(500),
        match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
        winner_id INTEGER REFERENCES players(id) ON DELETE SET NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_tournament_prizes
module Migrations
  def self.create_tournament_prizes(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS tournament_prizes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        placement_from INTEGER NOT NULL,
        placement_to INTEGER NOT NULL,
        prize_type VARCHAR(255) NOT NULL,
        amount REAL NOT NULL DEFAULT 0.0,
        description TEXT,
        packs_count INTEGER,
        season_points INTEGER NOT NULL DEFAULT 0,
        tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_awarded_prizes
module Migrations
  def self.create_awarded_prizes(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS awarded_prizes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        final_placement INTEGER NOT NULL,
        awarded_at DATETIME NOT NULL,
        claimed BOOLEAN NOT NULL DEFAULT false,
        claimed_at DATETIME,
        prize_id INTEGER NOT NULL REFERENCES tournament_prizes(id) ON DELETE RESTRICT,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end
