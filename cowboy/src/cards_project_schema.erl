-module(cards_project_schema).
-export([create_tables/0]).

-include("records.hrl").

create_tables() ->
    case mnesia:create_table(card, [
        {attributes, [id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(card_set, [
        {attributes, [id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(card_ruling, [
        {attributes, [id, ruling_text, published_at, source, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(card_ability, [
        {attributes, [id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(deck, [
        {attributes, [id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(deck_card, [
        {attributes, [id, quantity, is_commander, deck_id, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(deck_sideboard_card, [
        {attributes, [id, quantity, deck_id, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(deck_tag, [
        {attributes, [id, name, color, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(deck_tag_assignment, [
        {attributes, [id, deck_id, tag_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(player, [
        {attributes, [id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(player_season_stats, [
        {attributes, [id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(player_collection, [
        {attributes, [id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(friendship, [
        {attributes, [id, status, requester_id, receiver_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(achievement, [
        {attributes, [id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(player_achievement, [
        {attributes, [id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(crafting_recipe, [
        {attributes, [id, dust_cost, is_available, result_card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(crafting_ingredient, [
        {attributes, [id, quantity, recipe_id, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(season, [
        {attributes, [id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(tournament, [
        {attributes, [id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(tournament_judge, [
        {attributes, [id, role, tournament_id, player_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(tournament_registration, [
        {attributes, [id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(tournament_round, [
        {attributes, [id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(match, [
        {attributes, [id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(game, [
        {attributes, [id, game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(tournament_prize, [
        {attributes, [id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(awarded_prize, [
        {attributes, [id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(product, [
        {attributes, [id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(order, [
        {attributes, [id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(order_item, [
        {attributes, [id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(coupon, [
        {attributes, [id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(trade_listing, [
        {attributes, [id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(trade_bid, [
        {attributes, [id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(trade_transaction, [
        {attributes, [id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(card_price_history, [
        {attributes, [id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(trade_dispute, [
        {attributes, [id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(draft_session, [
        {attributes, [id, status, draft_type, seats, time_per_pick_seconds, completed_at, card_set_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(draft_participant, [
        {attributes, [id, seat_number, joined_at, session_id, player_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(draft_pick, [
        {attributes, [id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(article, [
        {attributes, [id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(article_tag, [
        {attributes, [id, name, slug, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(article_tag_assignment, [
        {attributes, [id, article_id, tag_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(article_comment, [
        {attributes, [id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(stream, [
        {attributes, [id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end,
    case mnesia:create_table(id_seq, [
        {attributes, [key, value]},
        {ram_copies, [node()]},
        {type, set}
    ]) of {atomic, ok} -> ok; {aborted, {already_exists, _}} -> ok end.

create_unique_indexes() ->
    mnesia:add_table_index(card_set, code),
    mnesia:add_table_index(player, display_name),
    mnesia:add_table_index(coupon, code),
    mnesia:add_table_index(article, slug),
    mnesia:add_table_index(article_tag, slug),
    ok.
