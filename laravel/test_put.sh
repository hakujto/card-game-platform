#!/usr/bin/env bash
BASE="http://localhost:8000/api"

ID_CardSet=1
ID_DeckTag=1
ID_Achievement=1
ID_Season=1
ID_Product=1
ID_Coupon=1
ID_ArticleTag=1
ID_Card=1
ID_PlayerSeasonStats=1
ID_OrderItem=1
ID_CardRuling=1
ID_CardAbility=1
ID_CraftingRecipe=1
ID_CardPriceHistory=1
ID_Player=1
ID_CraftingIngredient=1
ID_Deck=1
ID_PlayerCollection=1
ID_Friendship=1
ID_PlayerAchievement=1
ID_Tournament=1
ID_Match=1
ID_Order=1
ID_Tradelisting=1
ID_DraftParticipant=1
ID_ArticleComment=1
ID_Stream=1
ID_DeckCard=1
ID_DeckSideboardCard=1
ID_DeckTagAssignment=1
ID_TournamentJudge=1
ID_TournamentRegistration=1
ID_TournamentPrize=1
ID_TournamentRound=1
ID_Game=1
ID_TradeBid=1
ID_TradeTransaction=1
ID_DraftSession=1
ID_DraftPick=1
ID_Article=1
ID_AwardedPrize=1
ID_TradeDispute=1
ID_ArticleTagAssignment=1

echo && echo "=== PUT card_sets/$ID_CardSet ==="
curl -s -X PUT "$BASE/card_sets/$ID_CardSet" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"release_date\": \"2024-01-01\", \"set_type\": \"Core\", \"total_cards\": 1, \"description\": \"foo_description\", \"logo_url\": \"https://example.com/foo\"}" | python3 -m json.tool

echo && echo "=== PUT deck_tags/$ID_DeckTag ==="
curl -s -X PUT "$BASE/deck_tags/$ID_DeckTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | python3 -m json.tool

echo && echo "=== PUT achievements/$ID_Achievement ==="
curl -s -X PUT "$BASE/achievements/$ID_Achievement" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"icon_url\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"Common\", \"is_hidden\": true}" | python3 -m json.tool

echo && echo "=== PUT seasons/$ID_Season ==="
curl -s -X PUT "$BASE/seasons/$ID_Season" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"start_date\": \"2024-01-01\", \"end_date\": \"2024-01-01\", \"format\": \"Standard\", \"is_active\": true, \"reward_description\": \"foo_reward_description\"}" | python3 -m json.tool

echo && echo "=== PUT products/$ID_Product ==="
curl -s -X PUT "$BASE/products/$ID_Product" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"product_type\": \"SingleCard\", \"price\": \"1.00\", \"stock\": 1, \"active\": true, \"discount_percent\": 1, \"description\": \"foo_description\", \"image_url\": \"https://example.com/foo\", \"featured\": true, \"card_id\": ${ID_Card:-null}, \"card_set_id\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT coupons/$ID_Coupon ==="
curl -s -X PUT "$BASE/coupons/$ID_Coupon" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code\", \"discount_type\": \"Percent\", \"discount_value\": \"1.00\", \"min_order_value\": \"1.00\", \"max_uses\": 1, \"uses_count\": 1, \"valid_from\": \"2024-01-01T00:00:00Z\", \"valid_until\": \"2024-01-01T00:00:00Z\", \"is_active\": true}" | python3 -m json.tool

echo && echo "=== PUT article_tags/$ID_ArticleTag ==="
curl -s -X PUT "$BASE/article_tags/$ID_ArticleTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | python3 -m json.tool

echo && echo "=== PUT cards/$ID_Card ==="
curl -s -X PUT "$BASE/cards/$ID_Card" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"card_type\": \"Creature\", \"rarity\": \"Common\", \"mana_cost\": 1, \"mana_colors\": \"White\", \"attack\": 1, \"defense\": 1, \"loyalty\": 1, \"description\": \"foo_description\", \"flavor_text\": \"foo_flavor_text\", \"image_url\": \"https://example.com/foo\", \"artist_name\": \"foo_artist_name\", \"legal_formats\": \"Standard\", \"is_banned\": true, \"is_restricted\": true, \"power_level\": 1, \"set_id\": $ID_CardSet}" | python3 -m json.tool

echo && echo "=== PUT player_season_statses/$ID_PlayerSeasonStats ==="
curl -s -X PUT "$BASE/player_season_statses/$ID_PlayerSeasonStats" \
  -H "Content-Type: application/json" \
  -d "{\"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournament_wins\": 1, \"highest_rank\": \"Bronze\", \"season_points\": 1, \"season_id\": $ID_Season}" | python3 -m json.tool

echo && echo "=== PUT order_items/$ID_OrderItem ==="
curl -s -X PUT "$BASE/order_items/$ID_OrderItem" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"price_at_purchase\": \"1.00\", \"foil\": true, \"product_id\": $ID_Product}" | python3 -m json.tool

echo && echo "=== PUT card_rulings/$ID_CardRuling ==="
curl -s -X PUT "$BASE/card_rulings/$ID_CardRuling" \
  -H "Content-Type: application/json" \
  -d "{\"ruling_text\": \"foo_ruling_text\", \"published_at\": \"2024-01-01\", \"source\": \"foo_source\", \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT card_abilities/$ID_CardAbility ==="
curl -s -X PUT "$BASE/card_abilities/$ID_CardAbility" \
  -H "Content-Type: application/json" \
  -d "{\"ability_type\": \"Keyword\", \"keyword\": \"foo_keyword\", \"ability_text\": \"foo_ability_text\", \"timing\": \"Any\", \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT crafting_recipes/$ID_CraftingRecipe ==="
curl -s -X PUT "$BASE/crafting_recipes/$ID_CraftingRecipe" \
  -H "Content-Type: application/json" \
  -d "{\"dust_cost\": 1, \"is_available\": true, \"result_card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT card_price_histories/$ID_CardPriceHistory ==="
curl -s -X PUT "$BASE/card_price_histories/$ID_CardPriceHistory" \
  -H "Content-Type: application/json" \
  -d "{\"price_date\": \"2024-01-01\", \"avg_price\": \"1.00\", \"min_price\": \"1.00\", \"max_price\": \"1.00\", \"volume\": 1, \"foil\": true, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT players/$ID_Player ==="
curl -s -X PUT "$BASE/players/$ID_Player" \
  -H "Content-Type: application/json" \
  -d "{\"display_name\": \"foo_display_name\", \"rank\": \"Bronze\", \"rating\": 1, \"peak_rating\": 1, \"bio\": \"foo_bio\", \"country_code\": \"fo\", \"avatar_url\": \"https://example.com/foo\", \"preferred_format\": \"Standard\", \"is_verified\": true, \"created_at\": \"2024-01-01T00:00:00Z\", \"last_active_at\": \"2024-01-01T00:00:00Z\", \"season_stats_id\": $ID_PlayerSeasonStats}" | python3 -m json.tool

echo && echo "=== PUT crafting_ingredients/$ID_CraftingIngredient ==="
curl -s -X PUT "$BASE/crafting_ingredients/$ID_CraftingIngredient" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipe_id\": $ID_CraftingRecipe, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT decks/$ID_Deck ==="
curl -s -X PUT "$BASE/decks/$ID_Deck" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"is_public\": true, \"is_tournament_legal\": true, \"archetype\": \"Aggro\", \"wins\": 1, \"losses\": 1, \"created_at\": \"2024-01-01T00:00:00Z\", \"updated_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT player_collections/$ID_PlayerCollection ==="
curl -s -X PUT "$BASE/player_collections/$ID_PlayerCollection" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"Mint\", \"acquired_at\": \"2024-01-01T00:00:00Z\", \"acquired_via\": \"Purchase\", \"player_id\": $ID_Player, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT friendships/$ID_Friendship ==="
curl -s -X PUT "$BASE/friendships/$ID_Friendship" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"created_at\": \"2024-01-01T00:00:00Z\", \"requester_id\": $ID_Player, \"receiver_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT player_achievements/$ID_PlayerAchievement ==="
curl -s -X PUT "$BASE/player_achievements/$ID_PlayerAchievement" \
  -H "Content-Type: application/json" \
  -d "{\"earned_at\": \"2024-01-01T00:00:00Z\", \"progress\": 1, \"is_completed\": true, \"player_id\": $ID_Player, \"achievement_id\": $ID_Achievement}" | python3 -m json.tool

echo && echo "=== PUT tournaments/$ID_Tournament ==="
curl -s -X PUT "$BASE/tournaments/$ID_Tournament" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"tournament_type\": \"Swiss\", \"status\": \"Draft\", \"max_players\": 1, \"entry_fee\": \"1.00\", \"prize_pool\": \"1.00\", \"start_time\": \"2024-01-01T00:00:00Z\", \"end_time\": \"2024-01-01T00:00:00Z\", \"is_online\": true, \"location\": \"foo_location\", \"rules_text\": \"foo_rules_text\", \"created_at\": \"2024-01-01T00:00:00Z\", \"season_id\": $ID_Season, \"organizer_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT matches/$ID_Match ==="
curl -s -X PUT "$BASE/matches/$ID_Match" \
  -H "Content-Type: application/json" \
  -d "{\"table_number\": 1, \"status\": \"Pending\", \"player1_wins\": 1, \"player2_wins\": 1, \"started_at\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"result_notes\": \"foo_result_notes\", \"player1_id\": $ID_Player, \"player2_id\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT orders/$ID_Order ==="
curl -s -X PUT "$BASE/orders/$ID_Order" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"total\": \"1.00\", \"discount_applied\": \"1.00\", \"currency\": \"foo\", \"payment_method\": \"Card\", \"payment_reference\": \"foo_payment_reference\", \"shipping_address\": \"foo_shipping_address\", \"tracking_number\": \"foo_tracking_number\", \"created_at\": \"2024-01-01T00:00:00Z\", \"paid_at\": \"2024-01-01T00:00:00Z\", \"shipped_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player, \"items_id\": $ID_OrderItem, \"coupon_id\": ${ID_Coupon:-null}}" | python3 -m json.tool

echo && echo "=== PUT tradelistings/$ID_Tradelisting ==="
curl -s -X PUT "$BASE/tradelistings/$ID_Tradelisting" \
  -H "Content-Type: application/json" \
  -d "{\"listing_type\": \"FixedPrice\", \"asking_price\": \"1.00\", \"auction_start_price\": \"1.00\", \"auction_current_bid\": \"1.00\", \"auction_end_time\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"Mint\", \"quantity\": 1, \"status\": \"Active\", \"description\": \"foo_description\", \"created_at\": \"2024-01-01T00:00:00Z\", \"expires_at\": \"2024-01-01T00:00:00Z\", \"seller_id\": $ID_Player, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT draft_participants/$ID_DraftParticipant ==="
curl -s -X PUT "$BASE/draft_participants/$ID_DraftParticipant" \
  -H "Content-Type: application/json" \
  -d "{\"seat_number\": 1, \"joined_at\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT article_comments/$ID_ArticleComment ==="
curl -s -X PUT "$BASE/article_comments/$ID_ArticleComment" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"is_hidden\": true, \"created_at\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"parent_comment_id\": ${ID_ArticleComment:-null}}" | python3 -m json.tool

echo && echo "=== PUT streams/$ID_Stream ==="
curl -s -X PUT "$BASE/streams/$ID_Stream" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"stream_url\": \"https://example.com/foo\", \"platform\": \"Twitch\", \"status\": \"Scheduled\", \"viewer_count_peak\": 1, \"scheduled_start\": \"2024-01-01T00:00:00Z\", \"actual_start\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"vod_url\": \"https://example.com/foo\", \"tournament_id\": ${ID_Tournament:-null}, \"streamer_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT deck_cards/$ID_DeckCard ==="
curl -s -X PUT "$BASE/deck_cards/$ID_DeckCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"is_commander\": true, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X PUT "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s -X PUT "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" \
  -H "Content-Type: application/json" \
  -d "{\"deck_id\": $ID_Deck, \"tag_id\": $ID_DeckTag}" | python3 -m json.tool

echo && echo "=== PUT tournament_judges/$ID_TournamentJudge ==="
curl -s -X PUT "$BASE/tournament_judges/$ID_TournamentJudge" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"HeadJudge\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT tournament_registrations/$ID_TournamentRegistration ==="
curl -s -X PUT "$BASE/tournament_registrations/$ID_TournamentRegistration" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Registered\", \"seed\": 1, \"final_standing\": 1, \"points_earned\": 1, \"registered_at\": \"2024-01-01T00:00:00Z\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player, \"deck_id\": $ID_Deck}" | python3 -m json.tool

echo && echo "=== PUT tournament_prizes/$ID_TournamentPrize ==="
curl -s -X PUT "$BASE/tournament_prizes/$ID_TournamentPrize" \
  -H "Content-Type: application/json" \
  -d "{\"placement_from\": 1, \"placement_to\": 1, \"prize_type\": \"Currency\", \"amount\": \"1.00\", \"description\": \"foo_description\", \"packs_count\": 1, \"season_points\": 1, \"tournament_id\": $ID_Tournament}" | python3 -m json.tool

echo && echo "=== PUT tournament_rounds/$ID_TournamentRound ==="
curl -s -X PUT "$BASE/tournament_rounds/$ID_TournamentRound" \
  -H "Content-Type: application/json" \
  -d "{\"round_number\": 1, \"status\": \"Pending\", \"started_at\": \"2024-01-01T00:00:00Z\", \"ended_at\": \"2024-01-01T00:00:00Z\", \"time_limit_minutes\": 1, \"tournament_id\": $ID_Tournament, \"matches_id\": $ID_Match}" | python3 -m json.tool

echo && echo "=== PUT games/$ID_Game ==="
curl -s -X PUT "$BASE/games/$ID_Game" \
  -H "Content-Type: application/json" \
  -d "{\"game_number\": 1, \"winner_side\": \"Player1\", \"turns_played\": 1, \"duration_seconds\": 1, \"ended_by\": \"Normal\", \"replay_url\": \"https://example.com/foo\", \"match_id\": $ID_Match, \"winner_id\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT trade_bids/$ID_TradeBid ==="
curl -s -X PUT "$BASE/trade_bids/$ID_TradeBid" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": \"1.00\", \"placed_at\": \"2024-01-01T00:00:00Z\", \"is_winning\": true, \"listing_id\": $ID_Tradelisting, \"bidder_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT trade_transactions/$ID_TradeTransaction ==="
curl -s -X PUT "$BASE/trade_transactions/$ID_TradeTransaction" \
  -H "Content-Type: application/json" \
  -d "{\"final_price\": \"1.00\", \"platform_fee\": \"1.00\", \"status\": \"Pending\", \"completed_at\": \"2024-01-01T00:00:00Z\", \"listing_id\": $ID_Tradelisting, \"buyer_id\": $ID_Player, \"seller_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT draft_sessions/$ID_DraftSession ==="
curl -s -X PUT "$BASE/draft_sessions/$ID_DraftSession" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"WaitingForPlayers\", \"draft_type\": \"Booster\", \"seats\": 1, \"created_at\": \"2024-01-01T00:00:00Z\", \"completed_at\": \"2024-01-01T00:00:00Z\", \"card_set_id\": $ID_CardSet, \"participants_id\": $ID_DraftParticipant}" | python3 -m json.tool

echo && echo "=== PUT draft_picks/$ID_DraftPick ==="
curl -s -X PUT "$BASE/draft_picks/$ID_DraftPick" \
  -H "Content-Type: application/json" \
  -d "{\"pick_number\": 1, \"pack_number\": 1, \"picked_at\": \"2024-01-01T00:00:00Z\", \"participant_id\": $ID_DraftParticipant, \"card_id\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT articles/$ID_Article ==="
curl -s -X PUT "$BASE/articles/$ID_Article" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"cover_image_url\": \"https://example.com/foo\", \"status\": \"Draft\", \"article_type\": \"Guide\", \"view_count\": 1, \"published_at\": \"2024-01-01T00:00:00Z\", \"created_at\": \"2024-01-01T00:00:00Z\", \"updated_at\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"featured_deck_id\": ${ID_Deck:-null}, \"comments_id\": $ID_ArticleComment}" | python3 -m json.tool

echo && echo "=== PUT awarded_prizes/$ID_AwardedPrize ==="
curl -s -X PUT "$BASE/awarded_prizes/$ID_AwardedPrize" \
  -H "Content-Type: application/json" \
  -d "{\"final_placement\": 1, \"awarded_at\": \"2024-01-01T00:00:00Z\", \"claimed\": true, \"claimed_at\": \"2024-01-01T00:00:00Z\", \"prize_id\": $ID_TournamentPrize, \"player_id\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT trade_disputes/$ID_TradeDispute ==="
curl -s -X PUT "$BASE/trade_disputes/$ID_TradeDispute" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"ItemNotReceived\", \"description\": \"foo_description\", \"status\": \"Open\", \"resolution\": \"foo_resolution\", \"opened_at\": \"2024-01-01T00:00:00Z\", \"resolved_at\": \"2024-01-01T00:00:00Z\", \"transaction_id\": $ID_TradeTransaction, \"opened_by_id\": $ID_Player, \"resolved_by_id\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s -X PUT "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" \
  -H "Content-Type: application/json" \
  -d "{\"article_id\": $ID_Article, \"tag_id\": $ID_ArticleTag}" | python3 -m json.tool
