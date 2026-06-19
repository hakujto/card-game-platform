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
  -d "{\"name\": \"foo_name\", \"code\": \"fo_$RANDOM\", \"releaseDate\": \"2024-01-01\", \"rotationDate\": null, \"setType\": \"CORE\", \"totalCards\": 1, \"isRotated\": false, \"description\": \"foo_description\", \"logoUrl\": \"https://example.com/foo\"}" | python3 -m json.tool

echo && echo "=== PATCH deck_tags/$ID_DeckTag ==="
curl -s -X PATCH "$BASE/deck_tags/$ID_DeckTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | python3 -m json.tool

echo && echo "=== PATCH players/$ID_Player ==="
curl -s -X PATCH "$BASE/players/$ID_Player" \
  -H "Content-Type: application/json" \
  -d "{\"displayName\": \"foo_display_name_$RANDOM\", \"rank\": \"BRONZE\", \"rating\": 1, \"peakRating\": 1, \"bio\": \"foo_bio\", \"countryCode\": \"fo\", \"avatarUrl\": \"https://example.com/foo\", \"preferredFormat\": \"STANDARD\", \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"lastActiveAt\": \"2024-01-01T00:00:00Z\", \"userId\": $RANDOM}" | python3 -m json.tool

echo && echo "=== PUT achievements/$ID_Achievement ==="
curl -s -X PUT "$BASE/achievements/$ID_Achievement" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"iconUrl\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"COMMON\", \"isHidden\": true}" | python3 -m json.tool

echo && echo "=== PUT seasons/$ID_Season ==="
curl -s -X PUT "$BASE/seasons/$ID_Season" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"startDate\": \"2024-01-01\", \"endDate\": \"2024-01-02\", \"format\": \"STANDARD\", \"isActive\": true, \"rewardDescription\": \"foo_reward_description\"}" | python3 -m json.tool

echo && echo "=== PUT products/$ID_Product ==="
curl -s -X PUT "$BASE/products/$ID_Product" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"productType\": \"SINGLECARD\", \"price\": 1, \"stock\": 0, \"active\": true, \"discountPercent\": 1, \"description\": \"foo_description\", \"imageUrl\": \"https://example.com/foo\", \"featured\": true, \"cardId\": ${ID_Card:-null}, \"cardSetId\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT coupons/$ID_Coupon ==="
curl -s -X PUT "$BASE/coupons/$ID_Coupon" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code_$RANDOM\", \"discountType\": \"PERCENT\", \"discountValue\": 1, \"minOrderValue\": \"1.00\", \"maxUses\": null, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00Z\", \"validUntil\": \"2024-01-01T00:00:01Z\", \"isActive\": true}" | python3 -m json.tool

echo && echo "=== PATCH article_tags/$ID_ArticleTag ==="
curl -s -X PATCH "$BASE/article_tags/$ID_ArticleTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug_$RANDOM\"}" | python3 -m json.tool

echo && echo "=== PUT cards/$ID_Card ==="
curl -s -X PUT "$BASE/cards/$ID_Card" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"cardType\": \"CREATURE\", \"rarity\": \"COMMON\", \"manaCost\": 0, \"manaColors\": \"WHITE\", \"attack\": 1, \"defense\": 1, \"loyalty\": null, \"description\": \"foo_description\", \"flavorText\": \"foo_flavor_text\", \"imageUrl\": \"https://example.com/foo\", \"artistName\": \"foo_artist_name\", \"legalFormats\": \"STANDARD\", \"isBanned\": false, \"isRestricted\": false, \"powerLevel\": 1, \"setId\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT decks/$ID_Deck ==="
curl -s -X PUT "$BASE/decks/$ID_Deck" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"STANDARD\", \"isPublic\": true, \"isTournamentLegal\": false, \"archetype\": \"AGGRO\", \"wins\": 0, \"losses\": 0, \"draws\": 0, \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"playerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT articles/$ID_Article ==="
curl -s -X PUT "$BASE/articles/$ID_Article" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug_$RANDOM\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"coverImageUrl\": \"https://example.com/foo\", \"status\": \"DRAFT\", \"articleType\": \"GUIDE\", \"language\": \"EN\", \"viewCount\": 0, \"likesCount\": 0, \"isFeatured\": true, \"publishedAt\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"authorId\": ${ID_Player:-null}, \"featuredDeckId\": ${ID_Deck:-null}}" | python3 -m json.tool

echo && echo "=== PUT streams/$ID_Stream ==="
curl -s -X PUT "$BASE/streams/$ID_Stream" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"streamUrl\": \"https://example.com/foo\", \"status\": \"SCHEDULED\", \"platform\": \"TWITCH\", \"language\": \"EN\", \"isOfficial\": true, \"viewerCountPeak\": 0, \"scheduledStart\": \"2024-01-01T00:00:00Z\", \"actualStart\": null, \"endedAt\": null, \"vodUrl\": \"https://example.com/foo\", \"tournamentId\": ${ID_Tournament:-null}, \"streamerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournaments/$ID_Tournament ==="
curl -s -X PUT "$BASE/tournaments/$ID_Tournament" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"status\": \"DRAFT\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"maxPlayers\": 2, \"entryFee\": 0, \"prizePool\": 0, \"startTime\": \"2024-01-01T00:00:00Z\", \"endTime\": null, \"isOnline\": true, \"location\": \"foo_location\", \"rulesText\": \"foo_rules_text\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"seasonId\": ${ID_Season:-null}, \"organizerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT card_abilities/$ID_CardAbility ==="
curl -s -X PUT "$BASE/card_abilities/$ID_CardAbility" \
  -H "Content-Type: application/json" \
  -d "{\"abilityType\": \"KEYWORD\", \"keyword\": \"foo_keyword\", \"abilityText\": \"foo_ability_text\", \"timing\": \"ANY\", \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH player_collections/$ID_PlayerCollection ==="
curl -s -X PATCH "$BASE/player_collections/$ID_PlayerCollection" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"MINT\", \"acquiredAt\": \"2024-01-01T00:00:00Z\", \"acquiredVia\": \"PURCHASE\", \"playerId\": ${ID_Player:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT crafting_recipes/$ID_CraftingRecipe ==="
curl -s -X PUT "$BASE/crafting_recipes/$ID_CraftingRecipe" \
  -H "Content-Type: application/json" \
  -d "{\"dustCost\": 1, \"isAvailable\": true, \"resultCardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH trade_listings/$ID_TradeListing ==="
curl -s -X PATCH "$BASE/trade_listings/$ID_TradeListing" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"ACTIVE\", \"listingType\": \"FIXEDPRICE\", \"askingPrice\": \"1.00\", \"auctionStartPrice\": \"1.00\", \"auctionCurrentBid\": \"1.00\", \"auctionEndTime\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"MINT\", \"quantity\": 1, \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"expiresAt\": \"2024-01-01T00:00:00Z\", \"sellerId\": ${ID_Player:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH deck_cards/$ID_DeckCard ==="
curl -s -X PATCH "$BASE/deck_cards/$ID_DeckCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"isCommander\": false, \"deckId\": ${ID_Deck:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PATCH deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X PATCH "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deckId\": ${ID_Deck:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournament_prizes/$ID_TournamentPrize ==="
curl -s -X PUT "$BASE/tournament_prizes/$ID_TournamentPrize" \
  -H "Content-Type: application/json" \
  -d "{\"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"CURRENCY\", \"amount\": 0, \"description\": \"foo_description\", \"packsCount\": 1, \"seasonPoints\": 1, \"tournamentId\": ${ID_Tournament:-null}}" | python3 -m json.tool
