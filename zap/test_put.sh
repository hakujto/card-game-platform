#!/usr/bin/env bash
BASE="http://localhost:8080/api"

ID_CardSet=1
ID_DeckTag=1
ID_Player=1
ID_Achievement=1
ID_Season=1
ID_Product=1
ID_Coupon=1
ID_ArticleTag=1
ID_Card=1
ID_DraftSession=1
ID_Deck=1
ID_Friendship=1
ID_Order=1
ID_Article=1
ID_Stream=1
ID_PlayerAchievement=1
ID_PlayerSeasonStats=1
ID_Tournament=1
ID_CardRuling=1
ID_CardAbility=1
ID_PlayerCollection=1
ID_CraftingRecipe=1
ID_TradeListing=1
ID_CardPriceHistory=1
ID_DraftParticipant=1
ID_DeckCard=1
ID_DeckSideboardCard=1
ID_DeckTagAssignment=1
ID_OrderItem=1
ID_ArticleTagAssignment=1
ID_ArticleComment=1
ID_TournamentJudge=1
ID_TournamentRegistration=1
ID_TournamentRound=1
ID_TournamentPrize=1
ID_CraftingIngredient=1
ID_TradeBid=1
ID_TradeTransaction=1
ID_DraftPick=1
ID_Match=1
ID_AwardedPrize=1
ID_TradeDispute=1
ID_Game=1

echo && echo "=== PUT card_sets/$ID_CardSet ==="
curl -s -X PUT "$BASE/card_sets/$ID_CardSet" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"code\": \"$(LC_ALL=C tr -dc A-Z </dev/urandom | head -c2)\", \"release_date\": \"2024-01-01\", \"rotation_date\": null, \"set_type\": \"core\", \"total_cards\": 1, \"is_rotated\": false, \"description\": \"foo_description\", \"logo_url\": \"https://example.com/foo\"}" | python3 -m json.tool

echo && echo "=== PATCH deck_tags/$ID_DeckTag ==="
curl -s -X PATCH "$BASE/deck_tags/$ID_DeckTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\", \"color\": \"foo_col\"}" | python3 -m json.tool

echo && echo "=== PATCH players/$ID_Player ==="
curl -s -X PATCH "$BASE/players/$ID_Player" \
  -H "Content-Type: application/json" \
  -d "{\"bio\": \"foo_bio\"}" | python3 -m json.tool

echo && echo "=== PUT achievements/$ID_Achievement ==="
curl -s -X PUT "$BASE/achievements/$ID_Achievement" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"icon_url\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"common\", \"is_hidden\": true}" | python3 -m json.tool

echo && echo "=== PUT seasons/$ID_Season ==="
curl -s -X PUT "$BASE/seasons/$ID_Season" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"start_date\": \"2024-01-01\", \"end_date\": \"2024-01-02\", \"format\": \"standard\", \"is_active\": true, \"reward_description\": \"foo_reward_description\"}" | python3 -m json.tool

echo && echo "=== PUT products/$ID_Product ==="
curl -s -X PUT "$BASE/products/$ID_Product" \
  -H "Content-Type: application/json" \
  -d "{\"description\": \"foo_description\"}" | python3 -m json.tool

echo && echo "=== PUT coupons/$ID_Coupon ==="
curl -s -X PUT "$BASE/coupons/$ID_Coupon" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code_$RANDOM\", \"discount_type\": \"percent\", \"discount_value\": 1, \"min_order_value\": 1.00, \"max_uses\": null, \"uses_count\": 1, \"valid_from\": \"2024-01-01T00:00:00Z\", \"valid_until\": \"2024-01-01T00:00:01Z\", \"is_active\": true}" | python3 -m json.tool

echo && echo "=== PATCH article_tags/$ID_ArticleTag ==="
curl -s -X PATCH "$BASE/article_tags/$ID_ArticleTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug_$RANDOM\"}" | python3 -m json.tool

echo && echo "=== PUT cards/$ID_Card ==="
curl -s -X PUT "$BASE/cards/$ID_Card" \
  -H "Content-Type: application/json" \
  -d "{\"flavor_text\": \"foo_flavor_text\"}" | python3 -m json.tool

echo && echo "=== PUT decks/$ID_Deck ==="
curl -s -X PUT "$BASE/decks/$ID_Deck" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\"}" | python3 -m json.tool

echo && echo "=== PUT articles/$ID_Article ==="
curl -s -X PUT "$BASE/articles/$ID_Article" \
  -H "Content-Type: application/json" \
  -d "{\"excerpt\": \"foo_excerpt\"}" | python3 -m json.tool

echo && echo "=== PUT streams/$ID_Stream ==="
curl -s -X PUT "$BASE/streams/$ID_Stream" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"stream_url\": \"https://example.com/foo\", \"status\": \"scheduled\", \"platform\": \"twitch\", \"language\": \"e_n\", \"is_official\": true, \"viewer_count_peak\": 0, \"scheduled_start\": \"2024-01-01T00:00:00Z\", \"actual_start\": null, \"ended_at\": null, \"vod_url\": \"https://example.com/foo\", \"tournament_id\": ${ID_Tournament:-null}, \"streamer_id\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournaments/$ID_Tournament ==="
curl -s -X PUT "$BASE/tournaments/$ID_Tournament" \
  -H "Content-Type: application/json" \
  -d "{\"description\": \"foo_description\"}" | python3 -m json.tool

echo && echo "=== PUT card_abilities/$ID_CardAbility ==="
curl -s -X PUT "$BASE/card_abilities/$ID_CardAbility" \
  -H "Content-Type: application/json" \
  -d "{\"ability_type\": \"keyword\", \"keyword\": \"foo_keyword\", \"ability_text\": \"foo_ability_text\", \"timing\": \"any\", \"card_id\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH player_collections/$ID_PlayerCollection ==="
curl -s -X PATCH "$BASE/player_collections/$ID_PlayerCollection" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"mint\", \"acquired_at\": \"2024-01-01T00:00:00Z\", \"acquired_via\": \"purchase\", \"player_id\": ${ID_Player:-null}, \"card_id\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT crafting_recipes/$ID_CraftingRecipe ==="
curl -s -X PUT "$BASE/crafting_recipes/$ID_CraftingRecipe" \
  -H "Content-Type: application/json" \
  -d "{\"dust_cost\": 1, \"is_available\": true, \"result_card_id\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH trade_listings/$ID_TradeListing ==="
curl -s -X PATCH "$BASE/trade_listings/$ID_TradeListing" \
  -H "Content-Type: application/json" \
  -d "{\"public_id\": \"$(uuidgen | tr '[:upper:]' '[:lower:]')\", \"status\": \"active\", \"listing_type\": \"fixed_price\", \"asking_price\": 1.00, \"auction_start_price\": 1.00, \"auction_current_bid\": 1.00, \"auction_end_time\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"mint\", \"quantity\": 1, \"description\": \"foo_description\", \"created_at\": \"2024-01-01T00:00:00Z\", \"expires_at\": \"2024-01-01T00:00:00Z\", \"seller_id\": ${ID_Player:-null}, \"card_id\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH deck_cards/$ID_DeckCard ==="
curl -s -X PATCH "$BASE/deck_cards/$ID_DeckCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"is_commander\": false, \"deck_id\": ${ID_Deck:-null}, \"card_id\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X PATCH "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deck_id\": ${ID_Deck:-null}, \"card_id\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournament_prizes/$ID_TournamentPrize ==="
curl -s -X PUT "$BASE/tournament_prizes/$ID_TournamentPrize" \
  -H "Content-Type: application/json" \
  -d "{\"placement_from\": 1, \"placement_to\": 1, \"prize_type\": \"currency\", \"amount\": 0, \"description\": \"foo_description\", \"packs_count\": 1, \"season_points\": 1, \"tournament_id\": ${ID_Tournament:-null}}" | python3 -m json.tool
