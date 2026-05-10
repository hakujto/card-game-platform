CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  hashed_password TEXT,
  is_active INTEGER DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS cards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  card_type TEXT NOT NULL,
  rarity TEXT NOT NULL,
  mana_cost INTEGER NOT NULL,
  mana_colors TEXT NOT NULL,
  attack INTEGER,
  defense INTEGER,
  loyalty INTEGER,
  description TEXT NOT NULL,
  flavor_text TEXT,
  image_url TEXT,
  artist_name TEXT,
  legal_formats TEXT NOT NULL,
  is_banned INTEGER NOT NULL,
  is_restricted INTEGER NOT NULL,
  power_level INTEGER NOT NULL,
  set_id INTEGER NOT NULL,
  rulings_id INTEGER,
  abilities_id INTEGER,
  FOREIGN KEY (set_id) REFERENCES card_sets(id),
  FOREIGN KEY (rulings_id) REFERENCES card_rulings(id),
  FOREIGN KEY (abilities_id) REFERENCES card_abilities(id)
);

CREATE TABLE IF NOT EXISTS card_sets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  release_date TEXT NOT NULL,
  set_type TEXT NOT NULL,
  total_cards INTEGER NOT NULL,
  description TEXT,
  logo_url TEXT
);

CREATE TABLE IF NOT EXISTS card_rulings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ruling_text TEXT NOT NULL,
  published_at TEXT NOT NULL,
  source TEXT NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS card_abilities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ability_type TEXT NOT NULL,
  keyword TEXT,
  ability_text TEXT NOT NULL,
  timing TEXT,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS decks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  format TEXT NOT NULL,
  is_public INTEGER NOT NULL,
  is_tournament_legal INTEGER NOT NULL,
  archetype TEXT,
  wins INTEGER NOT NULL,
  losses INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  player_id INTEGER NOT NULL,
  FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS decks_cards_m2m (
  left_id  INTEGER NOT NULL REFERENCES decks(id),
  right_id INTEGER NOT NULL REFERENCES cards(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS decks_sideboard_cards_m2m (
  left_id  INTEGER NOT NULL REFERENCES decks(id),
  right_id INTEGER NOT NULL REFERENCES cards(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS decks_tags_m2m (
  left_id  INTEGER NOT NULL REFERENCES decks(id),
  right_id INTEGER NOT NULL REFERENCES deck_tags(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS deck_cards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quantity INTEGER NOT NULL,
  is_commander INTEGER NOT NULL,
  deck_id INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (deck_id) REFERENCES decks(id),
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS deck_sideboard_cards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quantity INTEGER NOT NULL,
  deck_id INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (deck_id) REFERENCES decks(id),
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS deck_tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  color TEXT
);

CREATE TABLE IF NOT EXISTS deck_tag_assignments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  deck_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  FOREIGN KEY (deck_id) REFERENCES decks(id),
  FOREIGN KEY (tag_id) REFERENCES deck_tags(id)
);

CREATE TABLE IF NOT EXISTS players (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  display_name TEXT NOT NULL,
  rank TEXT NOT NULL,
  rating INTEGER NOT NULL,
  peak_rating INTEGER NOT NULL,
  bio TEXT,
  country_code TEXT,
  avatar_url TEXT,
  preferred_format TEXT,
  is_verified INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  last_active_at TEXT,
  user_id INTEGER,
  season_stats_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (season_stats_id) REFERENCES player_season_statses(id)
);

CREATE TABLE IF NOT EXISTS players_achievements_m2m (
  left_id  INTEGER NOT NULL REFERENCES players(id),
  right_id INTEGER NOT NULL REFERENCES achievements(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS players_friends_m2m (
  left_id  INTEGER NOT NULL REFERENCES players(id),
  right_id INTEGER NOT NULL REFERENCES players(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS player_season_statses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wins INTEGER NOT NULL,
  losses INTEGER NOT NULL,
  draws INTEGER NOT NULL,
  tournament_wins INTEGER NOT NULL,
  highest_rank TEXT,
  season_points INTEGER NOT NULL,
  player_id INTEGER,
  season_id INTEGER NOT NULL,
  FOREIGN KEY (player_id) REFERENCES players(id),
  FOREIGN KEY (season_id) REFERENCES seasons(id)
);

CREATE TABLE IF NOT EXISTS player_collections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quantity INTEGER NOT NULL,
  foil INTEGER NOT NULL,
  condition TEXT NOT NULL,
  acquired_at TEXT NOT NULL,
  acquired_via TEXT NOT NULL,
  player_id INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (player_id) REFERENCES players(id),
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS friendships (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL,
  requester_id INTEGER NOT NULL,
  receiver_id INTEGER NOT NULL,
  FOREIGN KEY (requester_id) REFERENCES players(id),
  FOREIGN KEY (receiver_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS achievements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_url TEXT,
  points INTEGER NOT NULL,
  rarity TEXT NOT NULL,
  is_hidden INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS player_achievements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  earned_at TEXT NOT NULL,
  progress INTEGER NOT NULL,
  is_completed INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  achievement_id INTEGER NOT NULL,
  FOREIGN KEY (player_id) REFERENCES players(id),
  FOREIGN KEY (achievement_id) REFERENCES achievements(id)
);

CREATE TABLE IF NOT EXISTS crafting_recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dust_cost INTEGER NOT NULL,
  is_available INTEGER NOT NULL,
  result_card_id INTEGER NOT NULL,
  FOREIGN KEY (result_card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS crafting_recipes_required_cards_m2m (
  left_id  INTEGER NOT NULL REFERENCES crafting_recipes(id),
  right_id INTEGER NOT NULL REFERENCES cards(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS crafting_ingredients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quantity INTEGER NOT NULL,
  recipe_id INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (recipe_id) REFERENCES crafting_recipes(id),
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS seasons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  format TEXT NOT NULL,
  is_active INTEGER NOT NULL,
  reward_description TEXT
);

CREATE TABLE IF NOT EXISTS tournaments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  format TEXT NOT NULL,
  tournament_type TEXT NOT NULL,
  status TEXT NOT NULL,
  max_players INTEGER NOT NULL,
  entry_fee TEXT NOT NULL,
  prize_pool TEXT NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT,
  is_online INTEGER NOT NULL,
  location TEXT,
  rules_text TEXT,
  created_at TEXT NOT NULL,
  season_id INTEGER NOT NULL,
  organizer_id INTEGER NOT NULL,
  registrations_id INTEGER,
  rounds_id INTEGER,
  prizes_id INTEGER,
  FOREIGN KEY (season_id) REFERENCES seasons(id),
  FOREIGN KEY (organizer_id) REFERENCES players(id),
  FOREIGN KEY (registrations_id) REFERENCES tournament_registrations(id),
  FOREIGN KEY (rounds_id) REFERENCES tournament_rounds(id),
  FOREIGN KEY (prizes_id) REFERENCES tournament_prizes(id)
);

CREATE TABLE IF NOT EXISTS tournaments_judges_m2m (
  left_id  INTEGER NOT NULL REFERENCES tournaments(id),
  right_id INTEGER NOT NULL REFERENCES players(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS tournament_judges (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  role TEXT NOT NULL,
  tournament_id INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  FOREIGN KEY (tournament_id) REFERENCES tournaments(id),
  FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS tournament_registrations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status TEXT NOT NULL,
  seed INTEGER,
  final_standing INTEGER,
  points_earned INTEGER NOT NULL,
  registered_at TEXT NOT NULL,
  tournament_id INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  deck_id INTEGER NOT NULL,
  FOREIGN KEY (tournament_id) REFERENCES tournaments(id),
  FOREIGN KEY (player_id) REFERENCES players(id),
  FOREIGN KEY (deck_id) REFERENCES decks(id)
);

CREATE TABLE IF NOT EXISTS tournament_rounds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  round_number INTEGER NOT NULL,
  status TEXT NOT NULL,
  started_at TEXT,
  ended_at TEXT,
  time_limit_minutes INTEGER NOT NULL,
  tournament_id INTEGER NOT NULL,
  matches_id INTEGER NOT NULL,
  FOREIGN KEY (tournament_id) REFERENCES tournaments(id),
  FOREIGN KEY (matches_id) REFERENCES matches(id)
);

CREATE TABLE IF NOT EXISTS matches (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_number INTEGER,
  status TEXT NOT NULL,
  player1_wins INTEGER NOT NULL,
  player2_wins INTEGER NOT NULL,
  started_at TEXT,
  ended_at TEXT,
  result_notes TEXT,
  round_id INTEGER,
  player1_id INTEGER NOT NULL,
  player2_id INTEGER,
  games_id INTEGER,
  FOREIGN KEY (round_id) REFERENCES tournament_rounds(id),
  FOREIGN KEY (player1_id) REFERENCES players(id),
  FOREIGN KEY (player2_id) REFERENCES players(id),
  FOREIGN KEY (games_id) REFERENCES games(id)
);

CREATE TABLE IF NOT EXISTS games (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  game_number INTEGER NOT NULL,
  winner_side TEXT,
  turns_played INTEGER,
  duration_seconds INTEGER,
  ended_by TEXT,
  replay_url TEXT,
  match_id INTEGER NOT NULL,
  winner_id INTEGER,
  FOREIGN KEY (match_id) REFERENCES matches(id),
  FOREIGN KEY (winner_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS tournament_prizes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  placement_from INTEGER NOT NULL,
  placement_to INTEGER NOT NULL,
  prize_type TEXT NOT NULL,
  amount TEXT NOT NULL,
  description TEXT,
  packs_count INTEGER,
  season_points INTEGER NOT NULL,
  tournament_id INTEGER NOT NULL,
  FOREIGN KEY (tournament_id) REFERENCES tournaments(id)
);

CREATE TABLE IF NOT EXISTS awarded_prizes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  final_placement INTEGER NOT NULL,
  awarded_at TEXT NOT NULL,
  claimed INTEGER NOT NULL,
  claimed_at TEXT,
  prize_id INTEGER NOT NULL,
  player_id INTEGER NOT NULL,
  FOREIGN KEY (prize_id) REFERENCES tournament_prizes(id),
  FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  product_type TEXT NOT NULL,
  price TEXT NOT NULL,
  stock INTEGER NOT NULL,
  active INTEGER NOT NULL,
  discount_percent INTEGER NOT NULL,
  description TEXT,
  image_url TEXT,
  featured INTEGER NOT NULL,
  card_id INTEGER,
  card_set_id INTEGER,
  FOREIGN KEY (card_id) REFERENCES cards(id),
  FOREIGN KEY (card_set_id) REFERENCES card_sets(id)
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status TEXT NOT NULL,
  total TEXT NOT NULL,
  discount_applied TEXT NOT NULL,
  currency TEXT NOT NULL,
  payment_method TEXT,
  payment_reference TEXT,
  shipping_address TEXT,
  tracking_number TEXT,
  created_at TEXT NOT NULL,
  paid_at TEXT,
  shipped_at TEXT,
  player_id INTEGER NOT NULL,
  items_id INTEGER NOT NULL,
  coupon_id INTEGER,
  FOREIGN KEY (player_id) REFERENCES players(id),
  FOREIGN KEY (items_id) REFERENCES order_items(id),
  FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  quantity INTEGER NOT NULL,
  price_at_purchase TEXT NOT NULL,
  foil INTEGER NOT NULL,
  order_id INTEGER,
  product_id INTEGER NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS coupons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL,
  discount_type TEXT NOT NULL,
  discount_value TEXT NOT NULL,
  min_order_value TEXT NOT NULL,
  max_uses INTEGER,
  uses_count INTEGER NOT NULL,
  valid_from TEXT NOT NULL,
  valid_until TEXT NOT NULL,
  is_active INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS tradelistings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  listing_type TEXT NOT NULL,
  asking_price TEXT,
  auction_start_price TEXT,
  auction_current_bid TEXT,
  auction_end_time TEXT,
  foil INTEGER NOT NULL,
  condition TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  status TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  expires_at TEXT,
  seller_id INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  bids_id INTEGER,
  FOREIGN KEY (seller_id) REFERENCES players(id),
  FOREIGN KEY (card_id) REFERENCES cards(id),
  FOREIGN KEY (bids_id) REFERENCES trade_bids(id)
);

CREATE TABLE IF NOT EXISTS trade_bids (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount TEXT NOT NULL,
  placed_at TEXT NOT NULL,
  is_winning INTEGER NOT NULL,
  listing_id INTEGER NOT NULL,
  bidder_id INTEGER NOT NULL,
  FOREIGN KEY (listing_id) REFERENCES tradelistings(id),
  FOREIGN KEY (bidder_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS trade_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  final_price TEXT NOT NULL,
  platform_fee TEXT NOT NULL,
  status TEXT NOT NULL,
  completed_at TEXT,
  listing_id INTEGER NOT NULL,
  buyer_id INTEGER NOT NULL,
  seller_id INTEGER NOT NULL,
  FOREIGN KEY (listing_id) REFERENCES tradelistings(id),
  FOREIGN KEY (buyer_id) REFERENCES players(id),
  FOREIGN KEY (seller_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS card_price_histories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  price_date TEXT NOT NULL,
  avg_price TEXT NOT NULL,
  min_price TEXT NOT NULL,
  max_price TEXT NOT NULL,
  volume INTEGER NOT NULL,
  foil INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS trade_disputes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  reason TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL,
  resolution TEXT,
  opened_at TEXT NOT NULL,
  resolved_at TEXT,
  transaction_id INTEGER NOT NULL,
  opened_by_id INTEGER NOT NULL,
  resolved_by_id INTEGER,
  FOREIGN KEY (transaction_id) REFERENCES trade_transactions(id),
  FOREIGN KEY (opened_by_id) REFERENCES players(id),
  FOREIGN KEY (resolved_by_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS draft_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  status TEXT NOT NULL,
  draft_type TEXT NOT NULL,
  seats INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  completed_at TEXT,
  card_set_id INTEGER NOT NULL,
  participants_id INTEGER NOT NULL,
  FOREIGN KEY (card_set_id) REFERENCES card_sets(id),
  FOREIGN KEY (participants_id) REFERENCES draft_participants(id)
);

CREATE TABLE IF NOT EXISTS draft_participants (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  seat_number INTEGER NOT NULL,
  joined_at TEXT NOT NULL,
  session_id INTEGER,
  player_id INTEGER NOT NULL,
  drafted_cards_id INTEGER,
  FOREIGN KEY (session_id) REFERENCES draft_sessions(id),
  FOREIGN KEY (player_id) REFERENCES players(id),
  FOREIGN KEY (drafted_cards_id) REFERENCES draft_picks(id)
);

CREATE TABLE IF NOT EXISTS draft_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pick_number INTEGER NOT NULL,
  pack_number INTEGER NOT NULL,
  picked_at TEXT NOT NULL,
  participant_id INTEGER NOT NULL,
  card_id INTEGER NOT NULL,
  FOREIGN KEY (participant_id) REFERENCES draft_participants(id),
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE IF NOT EXISTS articles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  slug TEXT NOT NULL,
  body TEXT NOT NULL,
  excerpt TEXT,
  cover_image_url TEXT,
  status TEXT NOT NULL,
  article_type TEXT NOT NULL,
  view_count INTEGER NOT NULL,
  published_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  featured_deck_id INTEGER,
  comments_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES players(id),
  FOREIGN KEY (featured_deck_id) REFERENCES decks(id),
  FOREIGN KEY (comments_id) REFERENCES article_comments(id)
);

CREATE TABLE IF NOT EXISTS articles_tags_m2m (
  left_id  INTEGER NOT NULL REFERENCES articles(id),
  right_id INTEGER NOT NULL REFERENCES article_tags(id),
  PRIMARY KEY (left_id, right_id)
);

CREATE TABLE IF NOT EXISTS article_tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  slug TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS article_tag_assignments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  article_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  FOREIGN KEY (article_id) REFERENCES articles(id),
  FOREIGN KEY (tag_id) REFERENCES article_tags(id)
);

CREATE TABLE IF NOT EXISTS article_comments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  body TEXT NOT NULL,
  is_hidden INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  article_id INTEGER,
  author_id INTEGER NOT NULL,
  parent_comment_id INTEGER,
  FOREIGN KEY (article_id) REFERENCES articles(id),
  FOREIGN KEY (author_id) REFERENCES players(id),
  FOREIGN KEY (parent_comment_id) REFERENCES article_comments(id)
);

CREATE TABLE IF NOT EXISTS streams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  stream_url TEXT NOT NULL,
  platform TEXT NOT NULL,
  status TEXT NOT NULL,
  viewer_count_peak INTEGER NOT NULL,
  scheduled_start TEXT NOT NULL,
  actual_start TEXT,
  ended_at TEXT,
  vod_url TEXT,
  tournament_id INTEGER,
  streamer_id INTEGER NOT NULL,
  FOREIGN KEY (tournament_id) REFERENCES tournaments(id),
  FOREIGN KEY (streamer_id) REFERENCES players(id)
);
