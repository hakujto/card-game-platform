module cards_project.TestHelpers

open System
open System.IO
open Microsoft.AspNetCore.Mvc.Testing
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.DependencyInjection
open Giraffe
open Dapper
open cards_project.Database
open cards_project.Program

type ApiFactory() =
    inherit WebApplicationFactory<Startup>()

    let _dbPath = Path.GetTempFileName()

    override _.ConfigureWebHost(builder) =
        builder.ConfigureServices(fun services ->
            services.AddGiraffe() |> ignore
        ) |> ignore
        builder.Configure(fun app ->
            let conn = createConnection _dbPath
            let schema = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "schema.sql"))
            initializeSchema conn schema
            conn.Execute("INSERT OR IGNORE INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url) VALUES ('seed', 'seed', 'seed', NULL, 'Core', 1, 0, NULL, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO cards (public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id) VALUES ('00000000-0000-0000-0000-000000000000', 'seed', 'Creature', 'Common', 1, 'White', NULL, NULL, NULL, 'seed', NULL, NULL, NULL, 'Standard', 0, 0, 1, NULL, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO card_rulings (ruling_text, published_at, source, card_id) VALUES ('seed', 'seed', 'seed', 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO card_abilities (ability_type, keyword, ability_text, timing, card_id) VALUES ('Keyword', NULL, 'seed', NULL, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO players (public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id) VALUES ('00000000-0000-0000-0000-000000000000', 'seed', 'Bronze', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id) VALUES ('seed', NULL, 'Standard', 0, 0, NULL, 1, 1, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (1, 0, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO deck_sideboard_cards (quantity, deck_id, card_id) VALUES (1, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO deck_tags (name, slug, color) VALUES ('seed', NULL, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO deck_tag_assignments (deck_id, tag_id) VALUES (1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO seasons (name, start_date, end_date, format, is_active, reward_description) VALUES ('seed', 'seed', 'seed', 'Standard', 0, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO player_season_statses (wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id) VALUES (1, 1, 1, 1, NULL, 1, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id) VALUES (1, 0, 'Mint', 'seed', 'Purchase', 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO friendships (status, requester_id, receiver_id) VALUES ('Pending', 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES ('seed', 'seed', NULL, 1, 'Common', 0);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO player_achievements (earned_at, progress, is_completed, player_id, achievement_id) VALUES ('seed', 1, 0, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO crafting_recipes (dust_cost, is_available, result_card_id) VALUES (1, 0, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO crafting_ingredients (quantity, recipe_id, card_id) VALUES (1, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO tournaments (public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id) VALUES ('00000000-0000-0000-0000-000000000000', 'seed', NULL, 'Draft', NULL, 'Standard', 'Swiss', 1, 1.0, 1.0, 'seed', NULL, 0, NULL, NULL, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO tournament_judges (role, tournament_id, player_id) VALUES ('HeadJudge', 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES ('Registered', NULL, NULL, 1, 'seed', 1, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id) VALUES (1, 'Pending', NULL, NULL, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id) VALUES (NULL, 'Pending', 1, 1, NULL, NULL, NULL, 1, 1, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO games (game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id) VALUES (1, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (1, 1, 'Currency', 1.0, NULL, NULL, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO awarded_prizes (final_placement, awarded_at, claimed, claimed_at, prize_id, player_id) VALUES (1, 'seed', 0, NULL, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id) VALUES ('seed', 'SingleCard', 1.0, 1, 0, 1, NULL, NULL, 0, NULL, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id) VALUES ('Pending', 1.0, 1.0, 'seed', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO order_items (quantity, price_at_purchase, foil, order_id, product_id) VALUES (1, 1.0, 0, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active) VALUES ('seed', 'Percent', 1.0, 1.0, NULL, 1, 'seed', 'seed', 0);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id) VALUES ('00000000-0000-0000-0000-000000000000', 'Active', 'FixedPrice', NULL, NULL, NULL, NULL, 0, 'Mint', 1, NULL, NULL, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id) VALUES (1.0, 'seed', 0, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO trade_transactions (final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id) VALUES (1.0, 1.0, 'Pending', NULL, 1, 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO card_price_histories (price_date, avg_price, min_price, max_price, volume, foil, card_id) VALUES ('seed', 1.0, 1.0, 1.0, 1, 0, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO draft_sessions (status, draft_type, pack_contents, seats, time_per_pick_seconds, completed_at, card_set_id) VALUES ('WaitingForPlayers', 'Booster', NULL, 1, 1, NULL, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO draft_participants (seat_number, joined_at, session_id, player_id) VALUES (1, 'seed', 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO draft_picks (pick_number, pack_number, picked_at, participant_id, card_id) VALUES (1, 1, 'seed', 1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id) VALUES ('seed', 'seed', 'seed', NULL, NULL, 'Draft', 'Guide', 'EN', 1, 1, 1, 0, NULL, 1, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO article_tags (name, slug) VALUES ('seed', 'seed');") |> ignore
            conn.Execute("INSERT OR IGNORE INTO article_tag_assignments (article_id, tag_id) VALUES (1, 1);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO article_comments (body, is_hidden, article_id, author_id, parent_comment_id) VALUES ('seed', 0, 1, 1, NULL);") |> ignore
            conn.Execute("INSERT OR IGNORE INTO streams (title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id) VALUES ('seed', 'seed', 'Scheduled', 'Twitch', 'EN', 0, 1, 'seed', NULL, NULL, NULL, NULL, 1);") |> ignore
            app.UseGiraffe(webApp conn)
        ) |> ignore

    interface IDisposable with
        override _.Dispose() =
            base.Dispose()
            if File.Exists(_dbPath) then File.Delete(_dbPath)
