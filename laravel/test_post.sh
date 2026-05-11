#!/usr/bin/env bash
BASE="http://localhost:8000/api"

extract_id() {
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id']) if 'id' in d else (print('POST failed:', d, file=sys.stderr) or exit(1))"
}

ID_CardSet=""
ID_DeckTag=""
ID_Player=""
ID_Achievement=""
ID_Season=""
ID_Product=""
ID_Coupon=""
ID_ArticleTag=""
ID_Card=""
ID_DraftSession=""
ID_Deck=""
ID_Friendship=""
ID_Order=""
ID_Article=""
ID_Stream=""
ID_PlayerAchievement=""
ID_PlayerSeasonStats=""
ID_Tournament=""
ID_CardRuling=""
ID_CardAbility=""
ID_PlayerCollection=""
ID_CraftingRecipe=""
ID_Tradelisting=""
ID_CardPriceHistory=""
ID_DraftParticipant=""
ID_DeckCard=""
ID_DeckSideboardCard=""
ID_DeckTagAssignment=""
ID_OrderItem=""
ID_ArticleTagAssignment=""
ID_ArticleComment=""
ID_TournamentJudge=""
ID_TournamentRegistration=""
ID_TournamentRound=""
ID_TournamentPrize=""
ID_CraftingIngredient=""
ID_TradeBid=""
ID_TradeTransaction=""
ID_DraftPick=""
ID_Match=""
ID_AwardedPrize=""
ID_TradeDispute=""
ID_Game=""

ID_CardSet=$(curl -s -X POST "$BASE/card_sets" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"release_date\": \"2024-01-01\", \"set_type\": \"Core\", \"total_cards\": 1, \"description\": \"foo_description\", \"logo_url\": \"https://example.com/foo\"}" | extract_id)
echo "CardSet id=$ID_CardSet"

ID_DeckTag=$(curl -s -X POST "$BASE/deck_tags" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | extract_id)
echo "DeckTag id=$ID_DeckTag"

ID_Player=$(curl -s -X POST "$BASE/players" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"display_name\": \"foo_display_name\", \"rank\": \"Bronze\", \"rating\": 1, \"peak_rating\": 1, \"bio\": \"foo_bio\", \"country_code\": \"fo\", \"avatar_url\": \"https://example.com/foo\", \"preferred_format\": \"Standard\", \"is_verified\": true, \"created_at\": \"2024-01-01T00:00:00Z\", \"last_active_at\": \"2024-01-01T00:00:00Z\"}" | extract_id)
echo "Player id=$ID_Player"

ID_Achievement=$(curl -s -X POST "$BASE/achievements" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"icon_url\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"Common\", \"is_hidden\": true}" | extract_id)
echo "Achievement id=$ID_Achievement"

ID_Season=$(curl -s -X POST "$BASE/seasons" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"start_date\": \"2024-01-01\", \"end_date\": \"2024-01-01\", \"format\": \"Standard\", \"is_active\": true, \"reward_description\": \"foo_reward_description\"}" | extract_id)
echo "Season id=$ID_Season"

ID_Product=$(curl -s -X POST "$BASE/products" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"product_type\": \"SingleCard\", \"price\": \"1.00\", \"stock\": 1, \"active\": true, \"discount_percent\": 1, \"description\": \"foo_description\", \"image_url\": \"https://example.com/foo\", \"featured\": true, \"card_id\": ${ID_Card:-null}, \"card_set_id\": ${ID_CardSet:-null}}" | extract_id)
echo "Product id=$ID_Product"

ID_Coupon=$(curl -s -X POST "$BASE/coupons" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"code\": \"foo_code\", \"discount_type\": \"Percent\", \"discount_value\": \"1.00\", \"min_order_value\": \"1.00\", \"max_uses\": 1, \"uses_count\": 1, \"valid_from\": \"2024-01-01T00:00:00Z\", \"valid_until\": \"2024-01-01T00:00:00Z\", \"is_active\": true}" | extract_id)
echo "Coupon id=$ID_Coupon"

ID_ArticleTag=$(curl -s -X POST "$BASE/article_tags" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | extract_id)
echo "ArticleTag id=$ID_ArticleTag"

ID_Card=$(curl -s -X POST "$BASE/cards" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"card_type\": \"Creature\", \"rarity\": \"Common\", \"mana_cost\": 1, \"mana_colors\": \"White\", \"attack\": 1, \"defense\": 1, \"loyalty\": 1, \"description\": \"foo_description\", \"flavor_text\": \"foo_flavor_text\", \"image_url\": \"https://example.com/foo\", \"artist_name\": \"foo_artist_name\", \"legal_formats\": \"Standard\", \"is_banned\": true, \"is_restricted\": true, \"power_level\": 1, \"set_id\": $ID_CardSet}" | extract_id)
echo "Card id=$ID_Card"

ID_DraftSession=$(curl -s -X POST "$BASE/draft_sessions" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"status\": \"WaitingForPlayers\", \"draft_type\": \"Booster\", \"seats\": 1, \"created_at\": \"2024-01-01T00:00:00Z\", \"completed_at\": \"2024-01-01T00:00:00Z\", \"card_set_id\": $ID_CardSet}" | extract_id)
echo "DraftSession id=$ID_DraftSession"

ID_Deck=$(curl -s -X POST "$BASE/decks" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"is_public\": true, \"is_tournament_legal\": true, \"archetype\": \"Aggro\", \"wins\": 1, \"losses\": 1, \"created_at\": \"2024-01-01T00:00:00Z\", \"updated_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | extract_id)
echo "Deck id=$ID_Deck"

ID_Friendship=$(curl -s -X POST "$BASE/friendships" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"status\": \"Pending\", \"created_at\": \"2024-01-01T00:00:00Z\", \"requester_id\": $ID_Player, \"receiver_id\": $ID_Player}" | extract_id)
echo "Friendship id=$ID_Friendship"

ID_Order=$(curl -s -X POST "$BASE/orders" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"status\": \"Pending\", \"total\": \"1.00\", \"discount_applied\": \"1.00\", \"currency\": \"foo\", \"payment_method\": \"Card\", \"payment_reference\": \"foo_payment_reference\", \"shipping_address\": \"foo_shipping_address\", \"tracking_number\": \"foo_tracking_number\", \"created_at\": \"2024-01-01T00:00:00Z\", \"paid_at\": \"2024-01-01T00:00:00Z\", \"shipped_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player, \"coupon_id\": ${ID_Coupon:-null}}" | extract_id)
echo "Order id=$ID_Order"

ID_Article=$(curl -s -X POST "$BASE/articles" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"cover_image_url\": \"https://example.com/foo\", \"status\": \"Draft\", \"article_type\": \"Guide\", \"view_count\": 1, \"published_at\": \"2024-01-01T00:00:00Z\", \"created_at\": \"2024-01-01T00:00:00Z\", \"updated_at\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"featured_deck_id\": ${ID_Deck:-null}}" | extract_id)
echo "Article id=$ID_Article"

ID_Stream=$(curl -s -X POST "$BASE/streams" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"title\": \"foo_title\", \"stream_url\": \"https://example.com/foo\", \"platform\": \"Twitch\", \"status\": \"Scheduled\", \"viewer_count_peak\": 1, \"scheduled_start\": \"2024-01-01T00:00:00Z\", \"actual_start\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"vod_url\": \"https://example.com/foo\", \"tournament_id\": ${ID_Tournament:-null}, \"streamer_id\": $ID_Player}" | extract_id)
echo "Stream id=$ID_Stream"

ID_PlayerAchievement=$(curl -s -X POST "$BASE/player_achievements" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"earned_at\": \"2024-01-01T00:00:00Z\", \"progress\": 1, \"is_completed\": true, \"player_id\": $ID_Player, \"achievement_id\": $ID_Achievement}" | extract_id)
echo "PlayerAchievement id=$ID_PlayerAchievement"

ID_PlayerSeasonStats=$(curl -s -X POST "$BASE/player_season_statses" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournament_wins\": 1, \"highest_rank\": \"Bronze\", \"season_points\": 1, \"player_id\": $ID_Player, \"season_id\": $ID_Season}" | extract_id)
echo "PlayerSeasonStats id=$ID_PlayerSeasonStats"

ID_Tournament=$(curl -s -X POST "$BASE/tournaments" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"tournament_type\": \"Swiss\", \"status\": \"Draft\", \"max_players\": 1, \"entry_fee\": \"1.00\", \"prize_pool\": \"1.00\", \"start_time\": \"2024-01-01T00:00:00Z\", \"end_time\": \"2024-01-01T00:00:00Z\", \"is_online\": true, \"location\": \"foo_location\", \"rules_text\": \"foo_rules_text\", \"created_at\": \"2024-01-01T00:00:00Z\", \"season_id\": $ID_Season, \"organizer_id\": $ID_Player}" | extract_id)
echo "Tournament id=$ID_Tournament"

ID_CardRuling=$(curl -s -X POST "$BASE/card_rulings" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"ruling_text\": \"foo_ruling_text\", \"published_at\": \"2024-01-01\", \"source\": \"foo_source\", \"card_id\": $ID_Card}" | extract_id)
echo "CardRuling id=$ID_CardRuling"

ID_CardAbility=$(curl -s -X POST "$BASE/card_abilities" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"ability_type\": \"Keyword\", \"keyword\": \"foo_keyword\", \"ability_text\": \"foo_ability_text\", \"timing\": \"Any\", \"card_id\": $ID_Card}" | extract_id)
echo "CardAbility id=$ID_CardAbility"

ID_PlayerCollection=$(curl -s -X POST "$BASE/player_collections" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"Mint\", \"acquired_at\": \"2024-01-01T00:00:00Z\", \"acquired_via\": \"Purchase\", \"player_id\": $ID_Player, \"card_id\": $ID_Card}" | extract_id)
echo "PlayerCollection id=$ID_PlayerCollection"

ID_CraftingRecipe=$(curl -s -X POST "$BASE/crafting_recipes" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"dust_cost\": 1, \"is_available\": true, \"result_card_id\": $ID_Card}" | extract_id)
echo "CraftingRecipe id=$ID_CraftingRecipe"

ID_Tradelisting=$(curl -s -X POST "$BASE/tradelistings" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"listing_type\": \"FixedPrice\", \"asking_price\": \"1.00\", \"auction_start_price\": \"1.00\", \"auction_current_bid\": \"1.00\", \"auction_end_time\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"Mint\", \"quantity\": 1, \"status\": \"Active\", \"description\": \"foo_description\", \"created_at\": \"2024-01-01T00:00:00Z\", \"expires_at\": \"2024-01-01T00:00:00Z\", \"seller_id\": $ID_Player, \"card_id\": $ID_Card}" | extract_id)
echo "Tradelisting id=$ID_Tradelisting"

ID_CardPriceHistory=$(curl -s -X POST "$BASE/card_price_histories" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"price_date\": \"2024-01-01\", \"avg_price\": \"1.00\", \"min_price\": \"1.00\", \"max_price\": \"1.00\", \"volume\": 1, \"foil\": true, \"card_id\": $ID_Card}" | extract_id)
echo "CardPriceHistory id=$ID_CardPriceHistory"

ID_DraftParticipant=$(curl -s -X POST "$BASE/draft_participants" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"seat_number\": 1, \"joined_at\": \"2024-01-01T00:00:00Z\", \"session_id\": $ID_DraftSession, \"player_id\": $ID_Player}" | extract_id)
echo "DraftParticipant id=$ID_DraftParticipant"

ID_DeckCard=$(curl -s -X POST "$BASE/deck_cards" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"quantity\": 1, \"is_commander\": true, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | extract_id)
echo "DeckCard id=$ID_DeckCard"

ID_DeckSideboardCard=$(curl -s -X POST "$BASE/deck_sideboard_cards" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"quantity\": 1, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | extract_id)
echo "DeckSideboardCard id=$ID_DeckSideboardCard"

ID_DeckTagAssignment=$(curl -s -X POST "$BASE/deck_tag_assignments" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"deck_id\": $ID_Deck, \"tag_id\": $ID_DeckTag}" | extract_id)
echo "DeckTagAssignment id=$ID_DeckTagAssignment"

ID_OrderItem=$(curl -s -X POST "$BASE/order_items" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"quantity\": 1, \"price_at_purchase\": \"1.00\", \"foil\": true, \"order_id\": $ID_Order, \"product_id\": $ID_Product}" | extract_id)
echo "OrderItem id=$ID_OrderItem"

ID_ArticleTagAssignment=$(curl -s -X POST "$BASE/article_tag_assignments" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"article_id\": $ID_Article, \"tag_id\": $ID_ArticleTag}" | extract_id)
echo "ArticleTagAssignment id=$ID_ArticleTagAssignment"

ID_ArticleComment=$(curl -s -X POST "$BASE/article_comments" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"body\": \"foo_body\", \"is_hidden\": true, \"created_at\": \"2024-01-01T00:00:00Z\", \"article_id\": $ID_Article, \"author_id\": $ID_Player, \"parent_comment_id\": ${ID_ArticleComment:-null}}" | extract_id)
echo "ArticleComment id=$ID_ArticleComment"

ID_TournamentJudge=$(curl -s -X POST "$BASE/tournament_judges" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"role\": \"HeadJudge\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player}" | extract_id)
echo "TournamentJudge id=$ID_TournamentJudge"

ID_TournamentRegistration=$(curl -s -X POST "$BASE/tournament_registrations" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"status\": \"Registered\", \"seed\": 1, \"final_standing\": 1, \"points_earned\": 1, \"registered_at\": \"2024-01-01T00:00:00Z\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player, \"deck_id\": $ID_Deck}" | extract_id)
echo "TournamentRegistration id=$ID_TournamentRegistration"

ID_TournamentRound=$(curl -s -X POST "$BASE/tournament_rounds" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"round_number\": 1, \"status\": \"Pending\", \"started_at\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"time_limit_minutes\": 1, \"tournament_id\": $ID_Tournament}" | extract_id)
echo "TournamentRound id=$ID_TournamentRound"

ID_TournamentPrize=$(curl -s -X POST "$BASE/tournament_prizes" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"placement_from\": 1, \"placement_to\": 1, \"prize_type\": \"Currency\", \"amount\": \"1.00\", \"description\": \"foo_description\", \"packs_count\": 1, \"season_points\": 1, \"tournament_id\": $ID_Tournament}" | extract_id)
echo "TournamentPrize id=$ID_TournamentPrize"

ID_CraftingIngredient=$(curl -s -X POST "$BASE/crafting_ingredients" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"quantity\": 1, \"recipe_id\": $ID_CraftingRecipe, \"card_id\": $ID_Card}" | extract_id)
echo "CraftingIngredient id=$ID_CraftingIngredient"

ID_TradeBid=$(curl -s -X POST "$BASE/trade_bids" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"amount\": \"1.00\", \"placed_at\": \"2024-01-01T00:00:00Z\", \"is_winning\": true, \"listing_id\": $ID_Tradelisting, \"bidder_id\": $ID_Player}" | extract_id)
echo "TradeBid id=$ID_TradeBid"

ID_TradeTransaction=$(curl -s -X POST "$BASE/trade_transactions" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"final_price\": \"1.00\", \"platform_fee\": \"1.00\", \"status\": \"Pending\", \"completed_at\": \"2024-01-01T00:00:00Z\", \"listing_id\": $ID_Tradelisting, \"buyer_id\": $ID_Player, \"seller_id\": $ID_Player}" | extract_id)
echo "TradeTransaction id=$ID_TradeTransaction"

ID_DraftPick=$(curl -s -X POST "$BASE/draft_picks" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"pick_number\": 1, \"pack_number\": 1, \"picked_at\": \"2024-01-01T00:00:00Z\", \"participant_id\": $ID_DraftParticipant, \"card_id\": $ID_Card}" | extract_id)
echo "DraftPick id=$ID_DraftPick"

ID_Match=$(curl -s -X POST "$BASE/matches" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"table_number\": 1, \"status\": \"Pending\", \"player1_wins\": 1, \"player2_wins\": 1, \"started_at\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"result_notes\": \"foo_result_notes\", \"round_id\": $ID_TournamentRound, \"player1_id\": $ID_Player, \"player2_id\": ${ID_Player:-null}}" | extract_id)
echo "Match id=$ID_Match"

ID_AwardedPrize=$(curl -s -X POST "$BASE/awarded_prizes" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"final_placement\": 1, \"awarded_at\": \"2024-01-01T00:00:00Z\", \"claimed\": true, \"claimed_at\": \"2024-01-01T00:00:00Z\", \"prize_id\": $ID_TournamentPrize, \"player_id\": $ID_Player}" | extract_id)
echo "AwardedPrize id=$ID_AwardedPrize"

ID_TradeDispute=$(curl -s -X POST "$BASE/trade_disputes" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"reason\": \"ItemNotReceived\", \"description\": \"foo_description\", \"status\": \"Open\", \"resolution\": \"foo_resolution\", \"opened_at\": \"2024-01-01T00:00:00Z\", \"resolved_at\": \"2024-01-01T00:00:00Z\", \"transaction_id\": $ID_TradeTransaction, \"opened_by_id\": $ID_Player, \"resolved_by_id\": ${ID_Player:-null}}" | extract_id)
echo "TradeDispute id=$ID_TradeDispute"

ID_Game=$(curl -s -X POST "$BASE/games" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"game_number\": 1, \"winner_side\": \"Player1\", \"turns_played\": 1, \"duration_seconds\": 1, \"ended_by\": \"Normal\", \"replay_url\": \"https://example.com/foo\", \"match_id\": $ID_Match, \"winner_id\": ${ID_Player:-null}}" | extract_id)
echo "Game id=$ID_Game"
