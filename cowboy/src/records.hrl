%% Mnesia table: cards
-record(card, {
    id         :: integer(),
    name       :: binary(),
    card_type  :: atom(),
    rarity     :: atom(),
    mana_cost  :: integer(),
    mana_colors :: atom(),
    attack     :: integer() | undefined,
    defense    :: integer() | undefined,
    loyalty    :: integer() | undefined,
    description :: binary(),
    flavor_text :: binary() | undefined,
    image_url  :: binary() | undefined,
    artist_name :: binary() | undefined,
    legal_formats :: atom(),
    is_banned  :: boolean(),
    is_restricted :: boolean(),
    power_level :: integer(),
    set_id     :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: card_sets
-record(card_set, {
    id         :: integer(),
    name       :: binary(),
    code       :: binary(),
    release_date :: binary(),
    rotation_date :: binary() | undefined,
    set_type   :: atom(),
    total_cards :: integer(),
    is_rotated :: boolean(),
    description :: binary() | undefined,
    logo_url   :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: card_rulings
-record(card_ruling, {
    id         :: integer(),
    ruling_text :: binary(),
    published_at :: binary(),
    source     :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: card_abilities
-record(card_ability, {
    id         :: integer(),
    ability_type :: atom(),
    keyword    :: binary() | undefined,
    ability_text :: binary(),
    timing     :: atom() | undefined,
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: decks
-record(deck, {
    id         :: integer(),
    name       :: binary(),
    description :: binary() | undefined,
    format     :: atom(),
    is_public  :: boolean(),
    is_tournament_legal :: boolean(),
    archetype  :: atom() | undefined,
    wins       :: integer(),
    losses     :: integer(),
    draws      :: integer(),
    player_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: deck_cards
-record(deck_card, {
    id         :: integer(),
    quantity   :: integer(),
    is_commander :: boolean(),
    deck_id    :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: deck_sideboard_cards
-record(deck_sideboard_card, {
    id         :: integer(),
    quantity   :: integer(),
    deck_id    :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: deck_tags
-record(deck_tag, {
    id         :: integer(),
    name       :: binary(),
    color      :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: deck_tag_assignments
-record(deck_tag_assignment, {
    id         :: integer(),
    deck_id    :: binary(),
    tag_id     :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: players
-record(player, {
    id         :: integer(),
    display_name :: binary(),
    rank       :: atom(),
    rating     :: integer(),
    peak_rating :: integer(),
    bio        :: binary() | undefined,
    country_code :: binary() | undefined,
    avatar_url :: binary() | undefined,
    preferred_format :: atom() | undefined,
    is_verified :: boolean(),
    last_active_at :: binary() | undefined,
    user_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: player_season_statses
-record(player_season_stats, {
    id         :: integer(),
    wins       :: integer(),
    losses     :: integer(),
    draws      :: integer(),
    tournament_wins :: integer(),
    highest_rank :: atom() | undefined,
    season_points :: integer(),
    player_id  :: binary(),
    season_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: player_collections
-record(player_collection, {
    id         :: integer(),
    quantity   :: integer(),
    foil       :: boolean(),
    condition  :: atom(),
    acquired_at :: binary(),
    acquired_via :: atom(),
    player_id  :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: friendships
-record(friendship, {
    id         :: integer(),
    status     :: atom(),
    requester_id :: binary(),
    receiver_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: achievements
-record(achievement, {
    id         :: integer(),
    name       :: binary(),
    description :: binary(),
    icon_url   :: binary() | undefined,
    points     :: integer(),
    rarity     :: atom(),
    is_hidden  :: boolean(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: player_achievements
-record(player_achievement, {
    id         :: integer(),
    earned_at  :: binary(),
    progress   :: integer(),
    is_completed :: boolean(),
    player_id  :: binary(),
    achievement_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: crafting_recipes
-record(crafting_recipe, {
    id         :: integer(),
    dust_cost  :: integer(),
    is_available :: boolean(),
    result_card_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: crafting_ingredients
-record(crafting_ingredient, {
    id         :: integer(),
    quantity   :: integer(),
    recipe_id  :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: seasons
-record(season, {
    id         :: integer(),
    name       :: binary(),
    start_date :: binary(),
    end_date   :: binary(),
    format     :: atom(),
    is_active  :: boolean(),
    reward_description :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: tournaments
-record(tournament, {
    id         :: integer(),
    name       :: binary(),
    description :: binary() | undefined,
    status     :: atom(),
    format     :: atom(),
    tournament_type :: atom(),
    max_players :: integer(),
    entry_fee  :: float(),
    prize_pool :: float(),
    start_time :: binary(),
    end_time   :: binary() | undefined,
    is_online  :: boolean(),
    location   :: binary() | undefined,
    rules_text :: binary() | undefined,
    season_id  :: binary(),
    organizer_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: tournament_judges
-record(tournament_judge, {
    id         :: integer(),
    role       :: atom(),
    tournament_id :: binary(),
    player_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: tournament_registrations
-record(tournament_registration, {
    id         :: integer(),
    status     :: atom(),
    seed       :: integer() | undefined,
    final_standing :: integer() | undefined,
    points_earned :: integer(),
    registered_at :: binary(),
    tournament_id :: binary(),
    player_id  :: binary(),
    deck_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: tournament_rounds
-record(tournament_round, {
    id         :: integer(),
    round_number :: integer(),
    status     :: atom(),
    started_at :: binary() | undefined,
    ended_at   :: binary() | undefined,
    time_limit_minutes :: integer(),
    tournament_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: matches
-record(match, {
    id         :: integer(),
    table_number :: integer() | undefined,
    status     :: atom(),
    player1_wins :: integer(),
    player2_wins :: integer(),
    started_at :: binary() | undefined,
    ended_at   :: binary() | undefined,
    result_notes :: binary() | undefined,
    round_id   :: binary(),
    player1_id :: binary(),
    player2_id :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: games
-record(game, {
    id         :: integer(),
    game_number :: integer(),
    winner_side :: atom() | undefined,
    turns_played :: integer() | undefined,
    duration_seconds :: integer() | undefined,
    ended_by   :: atom() | undefined,
    replay_url :: binary() | undefined,
    match_id   :: binary(),
    winner_id  :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: tournament_prizes
-record(tournament_prize, {
    id         :: integer(),
    placement_from :: integer(),
    placement_to :: integer(),
    prize_type :: atom(),
    amount     :: float(),
    description :: binary() | undefined,
    packs_count :: integer() | undefined,
    season_points :: integer(),
    tournament_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: awarded_prizes
-record(awarded_prize, {
    id         :: integer(),
    final_placement :: integer(),
    awarded_at :: binary(),
    claimed    :: boolean(),
    claimed_at :: binary() | undefined,
    prize_id   :: binary(),
    player_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: products
-record(product, {
    id         :: integer(),
    name       :: binary(),
    product_type :: atom(),
    price      :: float(),
    stock      :: integer(),
    active     :: boolean(),
    discount_percent :: integer(),
    description :: binary() | undefined,
    image_url  :: binary() | undefined,
    featured   :: boolean(),
    card_id    :: binary() | undefined,
    card_set_id :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: orders
-record(order, {
    id         :: integer(),
    status     :: atom(),
    total      :: float(),
    discount_applied :: float(),
    currency   :: binary(),
    payment_method :: atom() | undefined,
    payment_reference :: binary() | undefined,
    shipping_address :: binary() | undefined,
    tracking_number :: binary() | undefined,
    paid_at    :: binary() | undefined,
    shipped_at :: binary() | undefined,
    player_id  :: binary(),
    coupon_id  :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: order_items
-record(order_item, {
    id         :: integer(),
    quantity   :: integer(),
    price_at_purchase :: float(),
    foil       :: boolean(),
    order_id   :: binary(),
    product_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: coupons
-record(coupon, {
    id         :: integer(),
    code       :: binary(),
    discount_type :: atom(),
    discount_value :: float(),
    min_order_value :: float(),
    max_uses   :: integer() | undefined,
    uses_count :: integer(),
    valid_from :: binary(),
    valid_until :: binary(),
    is_active  :: boolean(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: trade_listings
-record(trade_listing, {
    id         :: integer(),
    status     :: atom(),
    listing_type :: atom(),
    asking_price :: float() | undefined,
    auction_start_price :: float() | undefined,
    auction_current_bid :: float() | undefined,
    auction_end_time :: binary() | undefined,
    foil       :: boolean(),
    condition  :: atom(),
    quantity   :: integer(),
    description :: binary() | undefined,
    expires_at :: binary() | undefined,
    seller_id  :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: trade_bids
-record(trade_bid, {
    id         :: integer(),
    amount     :: float(),
    placed_at  :: binary(),
    is_winning :: boolean(),
    listing_id :: binary(),
    bidder_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: trade_transactions
-record(trade_transaction, {
    id         :: integer(),
    final_price :: float(),
    platform_fee :: float(),
    status     :: atom(),
    completed_at :: binary() | undefined,
    listing_id :: binary(),
    buyer_id   :: binary(),
    seller_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: card_price_histories
-record(card_price_history, {
    id         :: integer(),
    price_date :: binary(),
    avg_price  :: float(),
    min_price  :: float(),
    max_price  :: float(),
    volume     :: integer(),
    foil       :: boolean(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: trade_disputes
-record(trade_dispute, {
    id         :: integer(),
    status     :: atom(),
    reason     :: atom(),
    description :: binary(),
    resolution :: binary() | undefined,
    opened_at  :: binary(),
    resolved_at :: binary() | undefined,
    transaction_id :: binary(),
    opened_by_id :: binary(),
    resolved_by_id :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: draft_sessions
-record(draft_session, {
    id         :: integer(),
    status     :: atom(),
    draft_type :: atom(),
    seats      :: integer(),
    time_per_pick_seconds :: integer(),
    completed_at :: binary() | undefined,
    card_set_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: draft_participants
-record(draft_participant, {
    id         :: integer(),
    seat_number :: integer(),
    joined_at  :: binary(),
    session_id :: binary(),
    player_id  :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: draft_picks
-record(draft_pick, {
    id         :: integer(),
    pick_number :: integer(),
    pack_number :: integer(),
    picked_at  :: binary(),
    participant_id :: binary(),
    card_id    :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: articles
-record(article, {
    id         :: integer(),
    title      :: binary(),
    slug       :: binary(),
    body       :: binary(),
    excerpt    :: binary() | undefined,
    cover_image_url :: binary() | undefined,
    status     :: atom(),
    article_type :: atom(),
    language   :: atom(),
    view_count :: integer(),
    likes_count :: integer(),
    is_featured :: boolean(),
    published_at :: binary() | undefined,
    author_id  :: binary(),
    featured_deck_id :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: article_tags
-record(article_tag, {
    id         :: integer(),
    name       :: binary(),
    slug       :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: article_tag_assignments
-record(article_tag_assignment, {
    id         :: integer(),
    article_id :: binary(),
    tag_id     :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: article_comments
-record(article_comment, {
    id         :: integer(),
    body       :: binary(),
    is_hidden  :: boolean(),
    article_id :: binary(),
    author_id  :: binary(),
    parent_comment_id :: binary() | undefined,
    created_at :: binary(),
    updated_at :: binary()
}).

%% Mnesia table: streams
-record(stream, {
    id         :: integer(),
    title      :: binary(),
    stream_url :: binary(),
    status     :: atom(),
    platform   :: atom(),
    language   :: atom(),
    is_official :: boolean(),
    viewer_count_peak :: integer(),
    scheduled_start :: binary(),
    actual_start :: binary() | undefined,
    ended_at   :: binary() | undefined,
    vod_url    :: binary() | undefined,
    tournament_id :: binary() | undefined,
    streamer_id :: binary(),
    created_at :: binary(),
    updated_at :: binary()
}).

