-- Initial migration: create tables

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    public_id TEXT NOT NULL UNIQUE
,    name TEXT NOT NULL
,    card_type TEXT NOT NULL DEFAULT 'Creature'
,    rarity TEXT NOT NULL DEFAULT 'Common'
,    mana_cost INTEGER NOT NULL DEFAULT 0
,    mana_colors TEXT NOT NULL
,    attack INTEGER
,    defense INTEGER
,    loyalty INTEGER
,    description TEXT NOT NULL
,    flavor_text TEXT
,    image_url TEXT
,    artist_name TEXT
,    legal_formats TEXT NOT NULL
,    is_banned BOOLEAN NOT NULL DEFAULT 0
,    is_restricted BOOLEAN NOT NULL DEFAULT 0
,    power_level INTEGER NOT NULL DEFAULT 1
,    metadata TEXT
,    total_copies_in_circulation INTEGER NOT NULL DEFAULT 0
,    set_id INTEGER NOT NULL REFERENCES card_sets(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS cards_audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    record_id INTEGER NOT NULL,
    field TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS card_sets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    code TEXT NOT NULL UNIQUE
,    release_date TEXT NOT NULL
,    rotation_date TEXT
,    set_type TEXT NOT NULL DEFAULT 'Expansion'
,    total_cards INTEGER NOT NULL
,    is_rotated BOOLEAN NOT NULL DEFAULT 0
,    description TEXT
,    logo_url TEXT
);

CREATE TABLE IF NOT EXISTS card_rulings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    ruling_text TEXT NOT NULL
,    published_at TEXT NOT NULL
,    source TEXT NOT NULL
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS card_abilities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    ability_type TEXT NOT NULL DEFAULT 'Keyword'
,    keyword TEXT
,    ability_text TEXT NOT NULL
,    timing TEXT
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS decks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    description TEXT
,    format TEXT NOT NULL DEFAULT 'Standard'
,    is_public BOOLEAN NOT NULL DEFAULT 0
,    is_tournament_legal BOOLEAN NOT NULL DEFAULT 0
,    archetype TEXT
,    wins INTEGER NOT NULL DEFAULT 0
,    losses INTEGER NOT NULL DEFAULT 0
,    draws INTEGER NOT NULL DEFAULT 0
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS deck_cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    quantity INTEGER NOT NULL DEFAULT 1
,    is_commander BOOLEAN NOT NULL DEFAULT 0
,    deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS deck_sideboard_cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    quantity INTEGER NOT NULL DEFAULT 1
,    deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS deck_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    slug TEXT
,    color TEXT
);

CREATE TABLE IF NOT EXISTS deck_tag_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE CASCADE
,    tag_id INTEGER NOT NULL REFERENCES deck_tags(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    public_id TEXT NOT NULL UNIQUE
,    display_name TEXT NOT NULL UNIQUE
,    rank TEXT NOT NULL DEFAULT 'Bronze'
,    rating INTEGER NOT NULL DEFAULT 1000
,    peak_rating INTEGER NOT NULL DEFAULT 1000
,    bio TEXT
,    country_code TEXT
,    avatar_url TEXT
,    preferred_format TEXT
,    contact_email TEXT
,    win_rate_cached REAL
,    is_verified BOOLEAN NOT NULL DEFAULT 0
,    last_active_at TEXT
,    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS player_season_statses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    wins INTEGER NOT NULL DEFAULT 0
,    losses INTEGER NOT NULL DEFAULT 0
,    draws INTEGER NOT NULL DEFAULT 0
,    tournament_wins INTEGER NOT NULL DEFAULT 0
,    highest_rank TEXT
,    season_points INTEGER NOT NULL DEFAULT 0
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE
,    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS player_collections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    quantity INTEGER NOT NULL DEFAULT 1
,    foil BOOLEAN NOT NULL DEFAULT 0
,    condition TEXT NOT NULL DEFAULT 'Mint'
,    acquired_at TEXT NOT NULL
,    acquired_via TEXT NOT NULL DEFAULT 'Purchase'
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS friendships (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    status TEXT NOT NULL DEFAULT 'Pending'
,    requester_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE
,    receiver_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    description TEXT NOT NULL
,    icon_url TEXT
,    points INTEGER NOT NULL DEFAULT 10
,    rarity TEXT NOT NULL DEFAULT 'Common'
,    is_hidden BOOLEAN NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS player_achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    earned_at TEXT NOT NULL
,    progress INTEGER NOT NULL DEFAULT 0
,    is_completed BOOLEAN NOT NULL DEFAULT 0
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE
,    achievement_id INTEGER NOT NULL REFERENCES achievements(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS crafting_recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    dust_cost INTEGER NOT NULL
,    is_available BOOLEAN NOT NULL DEFAULT 1
,    result_card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS crafting_ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    quantity INTEGER NOT NULL DEFAULT 1
,    recipe_id INTEGER NOT NULL REFERENCES crafting_recipes(id) ON DELETE CASCADE
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS seasons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    start_date TEXT NOT NULL
,    end_date TEXT NOT NULL
,    format TEXT NOT NULL DEFAULT 'Standard'
,    is_active BOOLEAN NOT NULL DEFAULT 0
,    reward_description TEXT
);

CREATE TABLE IF NOT EXISTS tournaments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    public_id TEXT NOT NULL UNIQUE
,    name TEXT NOT NULL
,    description TEXT
,    status TEXT NOT NULL DEFAULT 'Draft'
,    bracket_data TEXT
,    format TEXT NOT NULL DEFAULT 'Standard'
,    tournament_type TEXT NOT NULL DEFAULT 'Swiss'
,    max_players INTEGER NOT NULL
,    entry_fee REAL NOT NULL DEFAULT 0
,    prize_pool REAL NOT NULL DEFAULT 0
,    start_time TEXT NOT NULL
,    end_time TEXT
,    is_online BOOLEAN NOT NULL DEFAULT 1
,    location TEXT
,    rules_text TEXT
,    season_id INTEGER NOT NULL REFERENCES seasons(id) ON DELETE RESTRICT
,    organizer_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS tournaments_audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    record_id INTEGER NOT NULL,
    field TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS tournament_judges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    role TEXT NOT NULL DEFAULT 'Judge'
,    tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS tournament_registrations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    status TEXT NOT NULL DEFAULT 'Registered'
,    seed INTEGER
,    final_standing INTEGER
,    points_earned INTEGER NOT NULL DEFAULT 0
,    registered_at TEXT NOT NULL
,    tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    deck_id INTEGER NOT NULL REFERENCES decks(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS tournament_rounds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    round_number INTEGER NOT NULL
,    status TEXT NOT NULL DEFAULT 'Pending'
,    started_at TEXT
,    ended_at TEXT
,    time_limit_minutes INTEGER NOT NULL DEFAULT 50
,    tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    table_number INTEGER
,    status TEXT NOT NULL DEFAULT 'Pending'
,    player1_wins INTEGER NOT NULL DEFAULT 0
,    player2_wins INTEGER NOT NULL DEFAULT 0
,    started_at TEXT
,    ended_at TEXT
,    result_notes TEXT
,    round_id INTEGER NOT NULL REFERENCES tournament_rounds(id) ON DELETE CASCADE
,    player1_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    player2_id INTEGER REFERENCES players(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    game_number INTEGER NOT NULL
,    winner_side TEXT
,    complexity_score REAL
,    turns_played INTEGER
,    duration_seconds INTEGER
,    ended_by TEXT
,    replay_url TEXT
,    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE
,    winner_id INTEGER REFERENCES players(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS tournament_prizes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    placement_from INTEGER NOT NULL
,    placement_to INTEGER NOT NULL
,    prize_type TEXT NOT NULL
,    amount REAL NOT NULL DEFAULT 0
,    description TEXT
,    packs_count INTEGER
,    season_points INTEGER NOT NULL DEFAULT 0
,    tournament_id INTEGER NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS awarded_prizes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    final_placement INTEGER NOT NULL
,    awarded_at TEXT NOT NULL
,    claimed BOOLEAN NOT NULL DEFAULT 0
,    claimed_at TEXT
,    prize_id INTEGER NOT NULL REFERENCES tournament_prizes(id) ON DELETE RESTRICT
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    product_type TEXT NOT NULL DEFAULT 'SingleCard'
,    price REAL NOT NULL
,    stock INTEGER NOT NULL DEFAULT 0
,    active BOOLEAN NOT NULL DEFAULT 1
,    discount_percent INTEGER NOT NULL DEFAULT 0
,    description TEXT
,    image_url TEXT
,    featured BOOLEAN NOT NULL DEFAULT 0
,    card_id INTEGER UNIQUE REFERENCES cards(id) ON DELETE SET NULL
,    card_set_id INTEGER REFERENCES card_sets(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    status TEXT NOT NULL DEFAULT 'Pending'
,    total REAL NOT NULL DEFAULT 0
,    discount_applied REAL NOT NULL DEFAULT 0
,    currency TEXT NOT NULL DEFAULT 'USD'
,    payment_method TEXT
,    payment_reference TEXT
,    shipping_address TEXT
,    tracking_number TEXT
,    paid_at TEXT
,    shipped_at TEXT
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    coupon_id INTEGER REFERENCES coupons(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS orders_audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    record_id INTEGER NOT NULL,
    field TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    quantity INTEGER NOT NULL
,    price_at_purchase REAL NOT NULL
,    foil BOOLEAN NOT NULL DEFAULT 0
,    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE
,    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS coupons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    code TEXT NOT NULL UNIQUE
,    discount_type TEXT NOT NULL DEFAULT 'Percent'
,    discount_value REAL NOT NULL
,    min_order_value REAL NOT NULL DEFAULT 0
,    max_uses INTEGER
,    uses_count INTEGER NOT NULL DEFAULT 0
,    valid_from TEXT NOT NULL
,    valid_until TEXT NOT NULL
,    is_active BOOLEAN NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS trade_listings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    public_id TEXT NOT NULL UNIQUE
,    status TEXT NOT NULL DEFAULT 'Active'
,    listing_type TEXT NOT NULL DEFAULT 'FixedPrice'
,    asking_price REAL
,    auction_start_price REAL
,    auction_current_bid REAL
,    auction_end_time TEXT
,    foil BOOLEAN NOT NULL DEFAULT 0
,    condition TEXT NOT NULL DEFAULT 'Mint'
,    quantity INTEGER NOT NULL DEFAULT 1
,    description TEXT
,    expires_at TEXT
,    seller_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS trade_bids (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    amount REAL NOT NULL
,    placed_at TEXT NOT NULL
,    is_winning BOOLEAN NOT NULL DEFAULT 0
,    listing_id INTEGER NOT NULL REFERENCES trade_listings(id) ON DELETE CASCADE
,    bidder_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS trade_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    final_price REAL NOT NULL
,    platform_fee REAL NOT NULL
,    status TEXT NOT NULL DEFAULT 'Pending'
,    completed_at TEXT
,    listing_id INTEGER NOT NULL UNIQUE REFERENCES trade_listings(id) ON DELETE RESTRICT
,    buyer_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    seller_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS trade_transactions_audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    record_id INTEGER NOT NULL,
    field TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS card_price_histories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    price_date TEXT NOT NULL
,    avg_price REAL NOT NULL
,    min_price REAL NOT NULL
,    max_price REAL NOT NULL
,    volume INTEGER NOT NULL
,    foil BOOLEAN NOT NULL DEFAULT 0
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS trade_disputes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    status TEXT NOT NULL DEFAULT 'Open'
,    reason TEXT NOT NULL
,    description TEXT NOT NULL
,    resolution TEXT
,    opened_at TEXT NOT NULL
,    resolved_at TEXT
,    transaction_id INTEGER NOT NULL UNIQUE REFERENCES trade_transactions(id) ON DELETE CASCADE
,    opened_by_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    resolved_by_id INTEGER REFERENCES players(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS draft_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    status TEXT NOT NULL DEFAULT 'WaitingForPlayers'
,    draft_type TEXT NOT NULL DEFAULT 'Booster'
,    pack_contents TEXT
,    seats INTEGER NOT NULL DEFAULT 8
,    time_per_pick_seconds INTEGER NOT NULL DEFAULT 30
,    completed_at TEXT
,    card_set_id INTEGER NOT NULL REFERENCES card_sets(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS draft_participants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    seat_number INTEGER NOT NULL
,    joined_at TEXT NOT NULL
,    session_id INTEGER NOT NULL REFERENCES draft_sessions(id) ON DELETE CASCADE
,    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS draft_picks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    pick_number INTEGER NOT NULL
,    pack_number INTEGER NOT NULL
,    picked_at TEXT NOT NULL
,    participant_id INTEGER NOT NULL REFERENCES draft_participants(id) ON DELETE CASCADE
,    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS articles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    title TEXT NOT NULL
,    slug TEXT NOT NULL UNIQUE
,    body TEXT NOT NULL
,    excerpt TEXT
,    cover_image_url TEXT
,    status TEXT NOT NULL DEFAULT 'Draft'
,    article_type TEXT NOT NULL DEFAULT 'Guide'
,    language TEXT NOT NULL DEFAULT 'EN'
,    view_count INTEGER NOT NULL DEFAULT 0
,    likes_count INTEGER NOT NULL DEFAULT 0
,    total_views_alltime INTEGER NOT NULL DEFAULT 0
,    is_featured BOOLEAN NOT NULL DEFAULT 0
,    published_at TEXT
,    author_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    featured_deck_id INTEGER REFERENCES decks(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS article_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    name TEXT NOT NULL
,    slug TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS article_tag_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE
,    tag_id INTEGER NOT NULL REFERENCES article_tags(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS article_comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    body TEXT NOT NULL
,    is_hidden BOOLEAN NOT NULL DEFAULT 0
,    article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE
,    author_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
,    parent_comment_id INTEGER REFERENCES article_comments(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS streams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
,    title TEXT NOT NULL
,    stream_url TEXT NOT NULL
,    status TEXT NOT NULL DEFAULT 'Scheduled'
,    platform TEXT NOT NULL DEFAULT 'Twitch'
,    language TEXT NOT NULL DEFAULT 'EN'
,    is_official BOOLEAN NOT NULL DEFAULT 0
,    viewer_count_peak INTEGER NOT NULL DEFAULT 0
,    scheduled_start TEXT NOT NULL
,    actual_start TEXT
,    ended_at TEXT
,    vod_url TEXT
,    tournament_id INTEGER REFERENCES tournaments(id) ON DELETE SET NULL
,    streamer_id INTEGER NOT NULL REFERENCES players(id) ON DELETE RESTRICT
);
