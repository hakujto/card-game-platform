# Migration: create_draft_sessions
module Migrations
  def self.create_draft_sessions(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS draft_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status VARCHAR(255) NOT NULL DEFAULT "WaitingForPlayers",
        draft_type VARCHAR(255) NOT NULL DEFAULT "Booster",
        pack_contents TEXT,
        seats INTEGER NOT NULL DEFAULT 8,
        time_per_pick_seconds INTEGER NOT NULL DEFAULT 30,
        completed_at DATETIME,
        card_set_id INTEGER NOT NULL REFERENCES card_sets(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_draft_participants
module Migrations
  def self.create_draft_participants(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS draft_participants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        seat_number INTEGER NOT NULL,
        joined_at DATETIME NOT NULL,
        session_id INTEGER NOT NULL REFERENCES draft_sessions(id) ON DELETE CASCADE,
        player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_draft_picks
module Migrations
  def self.create_draft_picks(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS draft_picks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pick_number INTEGER NOT NULL,
        pack_number INTEGER NOT NULL,
        picked_at DATETIME NOT NULL,
        participant_id INTEGER NOT NULL REFERENCES draft_participants(id) ON DELETE CASCADE,
        card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_articles
module Migrations
  def self.create_articles(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255) NOT NULL,
        slug VARCHAR(255) NOT NULL UNIQUE,
        body TEXT NOT NULL,
        excerpt TEXT,
        cover_image_url VARCHAR(500),
        status VARCHAR(255) NOT NULL DEFAULT "Draft",
        article_type VARCHAR(255) NOT NULL DEFAULT "Guide",
        language VARCHAR(255) NOT NULL DEFAULT "EN",
        view_count INTEGER NOT NULL DEFAULT 0,
        likes_count INTEGER NOT NULL DEFAULT 0,
        total_views_alltime BIGINT NOT NULL DEFAULT 0,
        is_featured BOOLEAN NOT NULL DEFAULT false,
        published_at DATETIME,
        author_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        featured_deck_id INTEGER REFERENCES decks(id) ON DELETE SET NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_article_tags
module Migrations
  def self.create_article_tags(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS article_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        slug VARCHAR(255) NOT NULL UNIQUE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_article_tag_assignments
module Migrations
  def self.create_article_tag_assignments(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS article_tag_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
        tag_id INTEGER NOT NULL REFERENCES article_tags(id) ON DELETE CASCADE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_article_comments
module Migrations
  def self.create_article_comments(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS article_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        body TEXT NOT NULL,
        is_hidden BOOLEAN NOT NULL DEFAULT false,
        article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
        author_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        parent_comment_id INTEGER REFERENCES article_comments(id) ON DELETE SET NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end

# Migration: create_streams
module Migrations
  def self.create_streams(db : DB::Database)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS streams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255) NOT NULL,
        stream_url VARCHAR(500) NOT NULL,
        status VARCHAR(255) NOT NULL DEFAULT "Scheduled",
        platform VARCHAR(255) NOT NULL DEFAULT "Twitch",
        language VARCHAR(255) NOT NULL DEFAULT "EN",
        is_official BOOLEAN NOT NULL DEFAULT false,
        viewer_count_peak INTEGER NOT NULL DEFAULT 0,
        scheduled_start DATETIME NOT NULL,
        actual_start DATETIME,
        ended_at DATETIME,
        vod_url VARCHAR(500),
        tournament_id INTEGER REFERENCES tournaments(id) ON DELETE SET NULL,
        streamer_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    SQL
  end
end
