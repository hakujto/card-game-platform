#!/usr/bin/env bash
BASE="http://localhost:3000/api"

extract_id() {
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id']) if 'id' in d else (print('POST failed:', d, file=sys.stderr) or exit(1))"
}

ID_CardSet=""
ID_DeckTag=""
ID_Achievement=""
ID_Season=""
ID_Product=""
ID_Coupon=""
ID_ArticleTag=""
ID_Card=""
ID_PlayerSeasonStats=""
ID_OrderItem=""
ID_CardRuling=""
ID_CardAbility=""
ID_CraftingRecipe=""
ID_CardPriceHistory=""
ID_Player=""
ID_CraftingIngredient=""
ID_Deck=""
ID_PlayerCollection=""
ID_Friendship=""
ID_PlayerAchievement=""
ID_Tournament=""
ID_Match=""
ID_Order=""
ID_Tradelisting=""
ID_DraftParticipant=""
ID_ArticleComment=""
ID_Stream=""
ID_DeckCard=""
ID_DeckSideboardCard=""
ID_DeckTagAssignment=""
ID_TournamentJudge=""
ID_TournamentRegistration=""
ID_TournamentPrize=""
ID_TournamentRound=""
ID_Game=""
ID_TradeBid=""
ID_TradeTransaction=""
ID_DraftSession=""
ID_DraftPick=""
ID_Article=""
ID_AwardedPrize=""
ID_TradeDispute=""
ID_ArticleTagAssignment=""

ID_CardSet=$(curl -s -X POST "$BASE/card_sets" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"release_date\": \"2024-01-01\", \"set_type\": \"core\", \"total_cards\": 1, \"description\": \"foo_description\", \"logo_url\": \"https://example.com/foo\"}" | extract_id)
echo "CardSet id=$ID_CardSet"

ID_DeckTag=$(curl -s -X POST "$BASE/deck_tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | extract_id)
echo "DeckTag id=$ID_DeckTag"

ID_Achievement=$(curl -s -X POST "$BASE/achievements" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"icon_url\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"common\", \"is_hidden\": true}" | extract_id)
echo "Achievement id=$ID_Achievement"

ID_Season=$(curl -s -X POST "$BASE/seasons" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"start_date\": \"2024-01-01\", \"end_date\": \"2024-01-01\", \"format\": \"standard\", \"is_active\": true, \"reward_description\": \"foo_reward_description\"}" | extract_id)
echo "Season id=$ID_Season"

ID_Product=$(curl -s -X POST "$BASE/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"product_type\": \"single_card\", \"price\": \"1.00\", \"stock\": 1, \"active\": true, \"discount_percent\": 1, \"description\": \"foo_description\", \"image_url\": \"https://example.com/foo\", \"featured\": true, \"card_id\": ${ID_Card:-null}, \"card_set_id\": ${ID_CardSet:-null}}" | extract_id)
echo "Product id=$ID_Product"

ID_Coupon=$(curl -s -X POST "$BASE/coupons" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code\", \"discount_type\": \"percent\", \"discount_value\": \"1.00\", \"min_order_value\": \"1.00\", \"max_uses\": 1, \"uses_count\": 1, \"valid_from\": \"2024-01-01T00:00:00Z\", \"valid_until\": \"2024-01-01T00:00:00Z\", \"is_active\": true}" | extract_id)
echo "Coupon id=$ID_Coupon"

ID_ArticleTag=$(curl -s -X POST "$BASE/article_tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | extract_id)
echo "ArticleTag id=$ID_ArticleTag"

ID_Card=$(curl -s -X POST "$BASE/cards" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"card_type\": \"creature\", \"rarity\": \"common\", \"mana_cost\": 1, \"mana_colors\": \"white\", \"attack\": 1, \"defense\": 1, \"loyalty\": 1, \"description\": \"foo_description\", \"flavor_text\": \"foo_flavor_text\", \"image_url\": \"https://example.com/foo\", \"artist_name\": \"foo_artist_name\", \"legal_formats\": \"standard\", \"is_banned\": true, \"is_restricted\": true, \"power_level\": 1, \"set_id\": $ID_CardSet}" | extract_id)
echo "Card id=$ID_Card"

ID_PlayerSeasonStats=$(curl -s -X POST "$BASE/player_season_statses" \
  -H "Content-Type: application/json" \
  -d "{\"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournament_wins\": 1, \"highest_rank\": \"bronze\", \"season_points\": 1, \"season_id\": $ID_Season}" | extract_id)
echo "PlayerSeasonStats id=$ID_PlayerSeasonStats"

ID_OrderItem=$(curl -s -X POST "$BASE/order_items" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"price_at_purchase\": \"1.00\", \"foil\": true, \"product_id\": $ID_Product}" | extract_id)
echo "OrderItem id=$ID_OrderItem"

ID_CardRuling=$(curl -s -X POST "$BASE/card_rulings" \
  -H "Content-Type: application/json" \
  -d "{\"ruling_text\": \"foo_ruling_text\", \"published_at\": \"2024-01-01\", \"source\": \"foo_source\", \"card_id\": $ID_Card}" | extract_id)
echo "CardRuling id=$ID_CardRuling"

ID_CardAbility=$(curl -s -X POST "$BASE/card_abilities" \
  -H "Content-Type: application/json" \
  -d "{\"ability_type\": \"keyword\", \"keyword\": \"foo_keyword\", \"ability_text\": \"foo_ability_text\", \"timing\": \"any\", \"card_id\": $ID_Card}" | extract_id)
echo "CardAbility id=$ID_CardAbility"

ID_CraftingRecipe=$(curl -s -X POST "$BASE/crafting_recipes" \
  -H "Content-Type: application/json" \
  -d "{\"dust_cost\": 1, \"is_available\": true, \"result_card_id\": $ID_Card}" | extract_id)
echo "CraftingRecipe id=$ID_CraftingRecipe"

ID_CardPriceHistory=$(curl -s -X POST "$BASE/card_price_histories" \
  -H "Content-Type: application/json" \
  -d "{\"price_date\": \"2024-01-01\", \"avg_price\": \"1.00\", \"min_price\": \"1.00\", \"max_price\": \"1.00\", \"volume\": 1, \"foil\": true, \"card_id\": $ID_Card}" | extract_id)
echo "CardPriceHistory id=$ID_CardPriceHistory"

ID_Player=$(curl -s -X POST "$BASE/players" \
  -H "Content-Type: application/json" \
  -d "{\"display_name\": \"foo_display_name\", \"rank\": \"bronze\", \"rating\": 1, \"peak_rating\": 1, \"bio\": \"foo_bio\", \"country_code\": \"fo\", \"avatar_url\": \"https://example.com/foo\", \"preferred_format\": \"standard\", \"is_verified\": true, \"created_at\": \"2024-01-01T00:00:00Z\", \"last_active_at\": \"2024-01-01T00:00:00Z\", \"season_stats_id\": $ID_PlayerSeasonStats}" | extract_id)
echo "Player id=$ID_Player"

ID_CraftingIngredient=$(curl -s -X POST "$BASE/crafting_ingredients" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipe_id\": $ID_CraftingRecipe, \"card_id\": $ID_Card}" | extract_id)
echo "CraftingIngredient id=$ID_CraftingIngredient"

ID_Deck=$(curl -s -X POST "$BASE/decks" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"standard\", \"is_public\": true, \"is_tournament_legal\": true, \"archetype\": \"aggro\", \"wins\": 1, \"losses\": 1, \"created_at\": \"2024-01-01T00:00:00Z\", \"updated_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | extract_id)
echo "Deck id=$ID_Deck"

ID_PlayerCollection=$(curl -s -X POST "$BASE/player_collections" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"mint\", \"acquired_at\": \"2024-01-01T00:00:00Z\", \"acquired_via\": \"purchase\", \"player_id\": $ID_Player, \"card_id\": $ID_Card}" | extract_id)
echo "PlayerCollection id=$ID_PlayerCollection"

ID_Friendship=$(curl -s -X POST "$BASE/friendships" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"pending\", \"created_at\": \"2024-01-01T00:00:00Z\", \"requester_id\": $ID_Player, \"receiver_id\": $ID_Player}" | extract_id)
echo "Friendship id=$ID_Friendship"

ID_PlayerAchievement=$(curl -s -X POST "$BASE/player_achievements" \
  -H "Content-Type: application/json" \
  -d "{\"earned_at\": \"2024-01-01T00:00:00Z\", \"progress\": 1, \"is_completed\": true, \"player_id\": $ID_Player, \"achievement_id\": $ID_Achievement}" | extract_id)
echo "PlayerAchievement id=$ID_PlayerAchievement"

ID_Tournament=$(curl -s -X POST "$BASE/tournaments" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"standard\", \"tournament_type\": \"swiss\", \"status\": \"draft\", \"max_players\": 1, \"entry_fee\": \"1.00\", \"prize_pool\": \"1.00\", \"start_time\": \"2024-01-01T00:00:00Z\", \"end_time\": \"2024-01-01T00:00:00Z\", \"is_online\": true, \"location\": \"foo_location\", \"rules_text\": \"foo_rules_text\", \"created_at\": \"2024-01-01T00:00:00Z\", \"season_id\": $ID_Season, \"organizer_id\": $ID_Player}" | extract_id)
echo "Tournament id=$ID_Tournament"

ID_Match=$(curl -s -X POST "$BASE/matches" \
  -H "Content-Type: application/json" \
  -d "{\"table_number\": 1, \"status\": \"pending\", \"player1_wins\": 1, \"player2_wins\": 1, \"started_at\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"result_notes\": \"foo_result_notes\", \"player1_id\": $ID_Player, \"player2_id\": ${ID_Player:-null}}" | extract_id)
echo "Match id=$ID_Match"

ID_Order=$(curl -s -X POST "$BASE/orders" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"pending\", \"total\": \"1.00\", \"discount_applied\": \"1.00\", \"currency\": \"foo\", \"payment_method\": \"card\", \"payment_reference\": \"foo_payment_reference\", \"shipping_address\": \"foo_shipping_address\", \"tracking_number\": \"foo_tracking_number\", \"created_at\": \"2024-01-01T00:00:00Z\", \"paid_at\": \"2024-01-01T00:00:00Z\", \"shipped_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player, \"items_id\": $ID_OrderItem, \"coupon_id\": ${ID_Coupon:-null}}" | extract_id)
echo "Order id=$ID_Order"

ID_Tradelisting=$(curl -s -X POST "$BASE/tradelistings" \
  -H "Content-Type: application/json" \
  -d "{\"listing_type\": \"fixed_price\", \"asking_price\": \"1.00\", \"auction_start_price\": \"1.00\", \"auction_current_bid\": \"1.00\", \"auction_end_time\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"mint\", \"quantity\": 1, \"status\": \"active\", \"description\": \"foo_description\", \"created_at\": \"2024-01-01T00:00:00Z\", \"expires_at\": \"2024-01-01T00:00:00Z\", \"seller_id\": $ID_Player, \"card_id\": $ID_Card}" | extract_id)
echo "Tradelisting id=$ID_Tradelisting"

ID_DraftParticipant=$(curl -s -X POST "$BASE/draft_participants" \
  -H "Content-Type: application/json" \
  -d "{\"seat_number\": 1, \"joined_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | extract_id)
echo "DraftParticipant id=$ID_DraftParticipant"

ID_ArticleComment=$(curl -s -X POST "$BASE/article_comments" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"is_hidden\": true, \"created_at\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"parent_comment_id\": ${ID_ArticleComment:-null}}" | extract_id)
echo "ArticleComment id=$ID_ArticleComment"

ID_Stream=$(curl -s -X POST "$BASE/streams" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"stream_url\": \"https://example.com/foo\", \"platform\": \"twitch\", \"status\": \"scheduled\", \"viewer_count_peak\": 1, \"scheduled_start\": \"2024-01-01T00:00:00Z\", \"actual_start\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"vod_url\": \"https://example.com/foo\", \"tournament_id\": ${ID_Tournament:-null}, \"streamer_id\": $ID_Player}" | extract_id)
echo "Stream id=$ID_Stream"

ID_DeckCard=$(curl -s -X POST "$BASE/deck_cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"is_commander\": true, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | extract_id)
echo "DeckCard id=$ID_DeckCard"

ID_DeckSideboardCard=$(curl -s -X POST "$BASE/deck_sideboard_cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | extract_id)
echo "DeckSideboardCard id=$ID_DeckSideboardCard"

ID_DeckTagAssignment=$(curl -s -X POST "$BASE/deck_tag_assignments" \
  -H "Content-Type: application/json" \
  -d "{\"deck_id\": $ID_Deck, \"tag_id\": $ID_DeckTag}" | extract_id)
echo "DeckTagAssignment id=$ID_DeckTagAssignment"

ID_TournamentJudge=$(curl -s -X POST "$BASE/tournament_judges" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"head_judge\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player}" | extract_id)
echo "TournamentJudge id=$ID_TournamentJudge"

ID_TournamentRegistration=$(curl -s -X POST "$BASE/tournament_registrations" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"registered\", \"seed\": 1, \"final_standing\": 1, \"points_earned\": 1, \"registered_at\": \"2024-01-01T00:00:00Z\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player, \"deck_id\": $ID_Deck}" | extract_id)
echo "TournamentRegistration id=$ID_TournamentRegistration"

ID_TournamentPrize=$(curl -s -X POST "$BASE/tournament_prizes" \
  -H "Content-Type: application/json" \
  -d "{\"placement_from\": 1, \"placement_to\": 1, \"prize_type\": \"currency\", \"amount\": \"1.00\", \"description\": \"foo_description\", \"packs_count\": 1, \"season_points\": 1, \"tournament_id\": $ID_Tournament}" | extract_id)
echo "TournamentPrize id=$ID_TournamentPrize"

ID_TournamentRound=$(curl -s -X POST "$BASE/tournament_rounds" \
  -H "Content-Type: application/json" \
  -d "{\"round_number\": 1, \"status\": \"pending\", \"started_at\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"time_limit_minutes\": 1, \"tournament_id\": $ID_Tournament, \"matches_id\": $ID_Match}" | extract_id)
echo "TournamentRound id=$ID_TournamentRound"

ID_Game=$(curl -s -X POST "$BASE/games" \
  -H "Content-Type: application/json" \
  -d "{\"game_number\": 1, \"winner_side\": \"player1\", \"turns_played\": 1, \"duration_seconds\": 1, \"ended_by\": \"normal\", \"replay_url\": \"https://example.com/foo\", \"match_id\": $ID_Match, \"winner_id\": ${ID_Player:-null}}" | extract_id)
echo "Game id=$ID_Game"

ID_TradeBid=$(curl -s -X POST "$BASE/trade_bids" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": \"1.00\", \"placed_at\": \"2024-01-01T00:00:00Z\", \"is_winning\": true, \"listing_id\": $ID_Tradelisting, \"bidder_id\": $ID_Player}" | extract_id)
echo "TradeBid id=$ID_TradeBid"

ID_TradeTransaction=$(curl -s -X POST "$BASE/trade_transactions" \
  -H "Content-Type: application/json" \
  -d "{\"final_price\": \"1.00\", \"platform_fee\": \"1.00\", \"status\": \"pending\", \"completed_at\": \"2024-01-01T00:00:00Z\", \"listing_id\": $ID_Tradelisting, \"buyer_id\": $ID_Player, \"seller_id\": $ID_Player}" | extract_id)
echo "TradeTransaction id=$ID_TradeTransaction"

ID_DraftSession=$(curl -s -X POST "$BASE/draft_sessions" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"waiting_for_players\", \"draft_type\": \"booster\", \"seats\": 1, \"created_at\": \"2024-01-01T00:00:00Z\", \"completed_at\": \"2024-01-01T00:00:00Z\", \"card_set_id\": $ID_CardSet, \"participants_id\": $ID_DraftParticipant}" | extract_id)
echo "DraftSession id=$ID_DraftSession"

ID_DraftPick=$(curl -s -X POST "$BASE/draft_picks" \
  -H "Content-Type: application/json" \
  -d "{\"pick_number\": 1, \"pack_number\": 1, \"picked_at\": \"2024-01-01T00:00:00Z\", \"participant_id\": $ID_DraftParticipant, \"card_id\": $ID_Card}" | extract_id)
echo "DraftPick id=$ID_DraftPick"

ID_Article=$(curl -s -X POST "$BASE/articles" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"cover_image_url\": \"https://example.com/foo\", \"status\": \"draft\", \"article_type\": \"guide\", \"view_count\": 1, \"published_at\": \"2024-01-01T00:00:00Z\", \"created_at\": \"2024-01-01T00:00:00Z\", \"updated_at\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"featured_deck_id\": ${ID_Deck:-null}, \"comments_id\": $ID_ArticleComment}" | extract_id)
echo "Article id=$ID_Article"

ID_AwardedPrize=$(curl -s -X POST "$BASE/awarded_prizes" \
  -H "Content-Type: application/json" \
  -d "{\"final_placement\": 1, \"awarded_at\": \"2024-01-01T00:00:00Z\", \"claimed\": true, \"claimed_at\": \"2024-01-01T00:00:00Z\", \"prize_id\": $ID_TournamentPrize, \"player_id\": $ID_Player}" | extract_id)
echo "AwardedPrize id=$ID_AwardedPrize"

ID_TradeDispute=$(curl -s -X POST "$BASE/trade_disputes" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"item_not_received\", \"description\": \"foo_description\", \"status\": \"open\", \"resolution\": \"foo_resolution\", \"opened_at\": \"2024-01-01T00:00:00Z\", \"resolved_at\": \"2024-01-01T00:00:00Z\", \"transaction_id\": $ID_TradeTransaction, \"opened_by_id\": $ID_Player, \"resolved_by_id\": ${ID_Player:-null}}" | extract_id)
echo "TradeDispute id=$ID_TradeDispute"

ID_ArticleTagAssignment=$(curl -s -X POST "$BASE/article_tag_assignments" \
  -H "Content-Type: application/json" \
  -d "{\"article_id\": $ID_Article, \"tag_id\": $ID_ArticleTag}" | extract_id)
echo "ArticleTagAssignment id=$ID_ArticleTagAssignment"
