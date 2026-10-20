#!/usr/bin/env bash
BASE="http://localhost:8080/api"

extract_id() {
  python3 -c "import sys,json; body=sys.stdin.read().strip(); d=json.loads(body) if body else {}; print(d['id']) if 'id' in d else (print('POST failed:', body or '(empty)', file=sys.stderr) or exit(1))"
}

json_uuid() { [ -n "$1" ] && printf '"%s"' "$1" || printf 'null'; }

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
ID_TradeListing=""
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

ID_CardSet=$(curl -s -X POST "$BASE/card-sets" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"code\": \"$(LC_ALL=C tr -dc A-Z </dev/urandom | head -c2)\", \"releaseDate\": \"2024-01-01\", \"rotationDate\": null, \"setType\": \"Core\", \"totalCards\": 1, \"isRotated\": false, \"description\": \"foo_description\", \"logoUrl\": \"https://example.com/foo\"}" | extract_id)
echo "CardSet id=$ID_CardSet"

ID_DeckTag=$(curl -s -X POST "$BASE/deck-tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\", \"color\": \"foo_col\"}" | extract_id)
echo "DeckTag id=$ID_DeckTag"

ID_Player=$(curl -s -X POST "$BASE/players" \
  -H "Content-Type: application/json" \
  -d "{\"publicId\": \"$(uuidgen | tr '[:upper:]' '[:lower:]')\", \"displayName\": \"test_player_001_$RANDOM\", \"rank\": \"Bronze\", \"rating\": 1000, \"peakRating\": 1000, \"bio\": \"foo_bio\", \"countryCode\": \"AB\", \"avatarUrl\": \"https://example.com/foo\", \"preferredFormat\": \"Standard\", \"contactEmail\": \"foo@example.com\", \"winRateCached\": 1.0, \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"lastActiveAt\": \"2024-01-01T00:00:00Z\"}" | extract_id)
echo "Player id=$ID_Player"

ID_Achievement=$(curl -s -X POST "$BASE/achievements" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"iconUrl\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"Common\", \"isHidden\": true}" | extract_id)
echo "Achievement id=$ID_Achievement"

ID_Season=$(curl -s -X POST "$BASE/seasons" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"startDate\": \"2024-01-01\", \"endDate\": \"2024-01-02\", \"format\": \"Standard\", \"isActive\": true, \"rewardDescription\": \"foo_reward_description\"}" | extract_id)
echo "Season id=$ID_Season"

ID_Product=$(curl -s -X POST "$BASE/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"productType\": \"SingleCard\", \"price\": 1, \"stock\": 0, \"active\": true, \"discountPercent\": 1, \"description\": \"foo_description\", \"imageUrl\": \"https://example.com/foo\", \"featured\": true, \"cardId\": $(json_uuid "$ID_Card"), \"cardSetId\": $(json_uuid "$ID_CardSet")}" | extract_id)
echo "Product id=$ID_Product"

ID_Coupon=$(curl -s -X POST "$BASE/coupons" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code_$RANDOM\", \"discountType\": \"Percent\", \"discountValue\": 1, \"minOrderValue\": 1.00, \"maxUses\": null, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00Z\", \"validUntil\": \"2024-01-01T00:00:01Z\", \"isActive\": true}" | extract_id)
echo "Coupon id=$ID_Coupon"

ID_ArticleTag=$(curl -s -X POST "$BASE/article-tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug_$RANDOM\"}" | extract_id)
echo "ArticleTag id=$ID_ArticleTag"

ID_Card=$(curl -s -X POST "$BASE/cards" \
  -H "Content-Type: application/json" \
  -d "{\"publicId\": \"$(uuidgen | tr '[:upper:]' '[:lower:]')\", \"name\": \"Test Lightning Bolt\", \"cardType\": \"Spell\", \"rarity\": \"Common\", \"manaCost\": 1, \"manaColors\": \"White\", \"attack\": 1, \"defense\": 1, \"loyalty\": null, \"description\": \"foo_description\", \"flavorText\": \"foo_flavor_text\", \"imageUrl\": \"https://example.com/foo\", \"artistName\": \"foo_artist_name\", \"legalFormats\": \"Standard\", \"isBanned\": false, \"isRestricted\": false, \"powerLevel\": 3, \"metadata\": \"{}\", \"totalCopiesInCirculation\": 1, \"setId\": $(json_uuid "$ID_CardSet")}" | extract_id)
echo "Card id=$ID_Card"

ID_DraftSession=$(curl -s -X POST "$BASE/draft-sessions" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"WaitingForPlayers\", \"draftType\": \"Booster\", \"packContents\": \"{}\", \"seats\": 2, \"timePerPickSeconds\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"completedAt\": null, \"cardSetId\": $(json_uuid "$ID_CardSet")}" | extract_id)
echo "DraftSession id=$ID_DraftSession"

ID_Deck=$(curl -s -X POST "$BASE/decks" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"isPublic\": true, \"isTournamentLegal\": false, \"archetype\": \"Aggro\", \"wins\": 0, \"losses\": 0, \"draws\": 0, \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"playerId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "Deck id=$ID_Deck"

ID_Friendship=$(curl -s -X POST "$BASE/friendships" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"requesterId\": $(json_uuid "$ID_Player"), \"receiverId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "Friendship id=$ID_Friendship"

ID_Order=$(curl -s -X POST "$BASE/orders" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"total\": 29.99, \"discountApplied\": 0.00, \"currency\": \"USD\", \"paymentMethod\": \"Card\", \"paymentReference\": \"foo_payment_reference\", \"shippingAddress\": \"foo_shipping_address\", \"trackingNumber\": \"foo_tracking_number\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"paidAt\": \"2024-01-01T00:00:00Z\", \"shippedAt\": null, \"playerId\": $(json_uuid "$ID_Player"), \"couponId\": $(json_uuid "$ID_Coupon")}" | extract_id)
echo "Order id=$ID_Order"

ID_Article=$(curl -s -X POST "$BASE/articles" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug_$RANDOM\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"coverImageUrl\": \"https://example.com/foo\", \"status\": \"Draft\", \"articleType\": \"Guide\", \"language\": \"EN\", \"viewCount\": 0, \"likesCount\": 0, \"totalViewsAlltime\": 1, \"isFeatured\": true, \"publishedAt\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"authorId\": $(json_uuid "$ID_Player"), \"featuredDeckId\": $(json_uuid "$ID_Deck")}" | extract_id)
echo "Article id=$ID_Article"

ID_Stream=$(curl -s -X POST "$BASE/streams" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"streamUrl\": \"https://example.com/foo\", \"status\": \"Scheduled\", \"platform\": \"Twitch\", \"language\": \"EN\", \"isOfficial\": true, \"viewerCountPeak\": 0, \"scheduledStart\": \"2024-01-01T00:00:00Z\", \"actualStart\": null, \"endedAt\": null, \"vodUrl\": \"https://example.com/foo\", \"tournamentId\": $(json_uuid "$ID_Tournament"), \"streamerId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "Stream id=$ID_Stream"

# PlayerAchievement: create not allowed — using id=1 as placeholder
ID_PlayerAchievement=00000000-0000-0000-0000-000000000000
echo "PlayerAchievement id=$ID_PlayerAchievement"

# PlayerSeasonStats: create not allowed — using id=1 as placeholder
ID_PlayerSeasonStats=00000000-0000-0000-0000-000000000000
echo "PlayerSeasonStats id=$ID_PlayerSeasonStats"

ID_Tournament=$(curl -s -X POST "$BASE/tournaments" \
  -H "Content-Type: application/json" \
  -d "{\"publicId\": \"$(uuidgen | tr '[:upper:]' '[:lower:]')\", \"name\": \"Test Tournament Alpha\", \"description\": \"foo_description\", \"status\": \"Draft\", \"bracketData\": \"{}\", \"format\": \"Standard\", \"tournamentType\": \"Swiss\", \"maxPlayers\": 8, \"entryFee\": 0, \"prizePool\": 0, \"startTime\": \"2024-01-01T00:00:00Z\", \"endTime\": null, \"isOnline\": true, \"location\": \"foo_location\", \"rulesText\": \"foo_rules_text\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"seasonId\": $(json_uuid "$ID_Season"), \"organizerId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "Tournament id=$ID_Tournament"

ID_CardRuling=$(curl -s -X POST "$BASE/card-rulings" \
  -H "Content-Type: application/json" \
  -d "{\"rulingText\": \"foo_ruling_text\", \"publishedAt\": \"2024-01-01\", \"source\": \"foo_source\", \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "CardRuling id=$ID_CardRuling"

ID_CardAbility=$(curl -s -X POST "$BASE/card-abilities" \
  -H "Content-Type: application/json" \
  -d "{\"abilityType\": \"Keyword\", \"keyword\": \"foo_keyword\", \"abilityText\": \"foo_ability_text\", \"timing\": \"Any\", \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "CardAbility id=$ID_CardAbility"

ID_PlayerCollection=$(curl -s -X POST "$BASE/player-collections" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"Mint\", \"acquiredAt\": \"2024-01-01T00:00:00Z\", \"acquiredVia\": \"Purchase\", \"playerId\": $(json_uuid "$ID_Player"), \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "PlayerCollection id=$ID_PlayerCollection"

ID_CraftingRecipe=$(curl -s -X POST "$BASE/crafting-recipes" \
  -H "Content-Type: application/json" \
  -d "{\"dustCost\": 1, \"isAvailable\": true, \"resultCardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "CraftingRecipe id=$ID_CraftingRecipe"

ID_TradeListing=$(curl -s -X POST "$BASE/trade-listings" \
  -H "Content-Type: application/json" \
  -d "{\"publicId\": \"$(uuidgen | tr '[:upper:]' '[:lower:]')\", \"status\": \"Active\", \"listingType\": \"FixedPrice\", \"askingPrice\": 1.00, \"auctionStartPrice\": 1.00, \"auctionCurrentBid\": 1.00, \"auctionEndTime\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"Mint\", \"quantity\": 1, \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"expiresAt\": \"2024-01-01T00:00:00Z\", \"sellerId\": $(json_uuid "$ID_Player"), \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "TradeListing id=$ID_TradeListing"

# CardPriceHistory: create not allowed — using id=1 as placeholder
ID_CardPriceHistory=00000000-0000-0000-0000-000000000000
echo "CardPriceHistory id=$ID_CardPriceHistory"

ID_DraftParticipant=$(curl -s -X POST "$BASE/draft-participants" \
  -H "Content-Type: application/json" \
  -d "{\"seatNumber\": 1, \"joinedAt\": \"2024-01-01T00:00:00Z\", \"sessionId\": $(json_uuid "$ID_DraftSession"), \"playerId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "DraftParticipant id=$ID_DraftParticipant"

ID_DeckCard=$(curl -s -X POST "$BASE/deck-cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"isCommander\": false, \"deckId\": $(json_uuid "$ID_Deck"), \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "DeckCard id=$ID_DeckCard"

ID_DeckSideboardCard=$(curl -s -X POST "$BASE/deck-sideboard-cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deckId\": $(json_uuid "$ID_Deck"), \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "DeckSideboardCard id=$ID_DeckSideboardCard"

ID_DeckTagAssignment=$(curl -s -X POST "$BASE/deck-tag-assignments" \
  -H "Content-Type: application/json" \
  -d "{\"deckId\": $(json_uuid "$ID_Deck"), \"tagId\": $(json_uuid "$ID_DeckTag")}" | extract_id)
echo "DeckTagAssignment id=$ID_DeckTagAssignment"

ID_OrderItem=$(curl -s -X POST "$BASE/order-items" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"priceAtPurchase\": 0, \"foil\": true, \"orderId\": $(json_uuid "$ID_Order"), \"productId\": $(json_uuid "$ID_Product")}" | extract_id)
echo "OrderItem id=$ID_OrderItem"

ID_ArticleTagAssignment=$(curl -s -X POST "$BASE/article-tag-assignments" \
  -H "Content-Type: application/json" \
  -d "{\"articleId\": $(json_uuid "$ID_Article"), \"tagId\": $(json_uuid "$ID_ArticleTag")}" | extract_id)
echo "ArticleTagAssignment id=$ID_ArticleTagAssignment"

ID_ArticleComment=$(curl -s -X POST "$BASE/article-comments" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"isHidden\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"articleId\": $(json_uuid "$ID_Article"), \"authorId\": $(json_uuid "$ID_Player"), \"parentCommentId\": $(json_uuid "$ID_ArticleComment")}" | extract_id)
echo "ArticleComment id=$ID_ArticleComment"

ID_TournamentJudge=$(curl -s -X POST "$BASE/tournament-judges" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"HeadJudge\", \"tournamentId\": $(json_uuid "$ID_Tournament"), \"playerId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "TournamentJudge id=$ID_TournamentJudge"

ID_TournamentRegistration=$(curl -s -X POST "$BASE/tournament-registrations" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Registered\", \"seed\": null, \"finalStanding\": null, \"pointsEarned\": 0, \"registeredAt\": \"2024-01-01T00:00:00Z\", \"tournamentId\": $(json_uuid "$ID_Tournament"), \"playerId\": $(json_uuid "$ID_Player"), \"deckId\": $(json_uuid "$ID_Deck")}" | extract_id)
echo "TournamentRegistration id=$ID_TournamentRegistration"

ID_TournamentRound=$(curl -s -X POST "$BASE/tournament-rounds" \
  -H "Content-Type: application/json" \
  -d "{\"roundNumber\": 1, \"status\": \"Pending\", \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": null, \"timeLimitMinutes\": 1, \"tournamentId\": $(json_uuid "$ID_Tournament")}" | extract_id)
echo "TournamentRound id=$ID_TournamentRound"

ID_TournamentPrize=$(curl -s -X POST "$BASE/tournament-prizes" \
  -H "Content-Type: application/json" \
  -d "{\"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"Currency\", \"amount\": 0, \"description\": \"foo_description\", \"packsCount\": 1, \"seasonPoints\": 1, \"tournamentId\": $(json_uuid "$ID_Tournament")}" | extract_id)
echo "TournamentPrize id=$ID_TournamentPrize"

ID_CraftingIngredient=$(curl -s -X POST "$BASE/crafting-ingredients" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipeId\": $(json_uuid "$ID_CraftingRecipe"), \"cardId\": $(json_uuid "$ID_Card")}" | extract_id)
echo "CraftingIngredient id=$ID_CraftingIngredient"

ID_TradeBid=$(curl -s -X POST "$BASE/trade-bids" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": 1, \"placedAt\": \"2024-01-01T00:00:00Z\", \"isWinning\": true, \"listingId\": $(json_uuid "$ID_TradeListing"), \"bidderId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "TradeBid id=$ID_TradeBid"

# TradeTransaction: create not allowed — using id=1 as placeholder
ID_TradeTransaction=00000000-0000-0000-0000-000000000000
echo "TradeTransaction id=$ID_TradeTransaction"

# DraftPick: create not allowed — using id=1 as placeholder
ID_DraftPick=00000000-0000-0000-0000-000000000000
echo "DraftPick id=$ID_DraftPick"

ID_Match=$(curl -s -X POST "$BASE/matches" \
  -H "Content-Type: application/json" \
  -d "{\"tableNumber\": 1, \"status\": \"Pending\", \"player1Wins\": 0, \"player2Wins\": 0, \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": null, \"resultNotes\": \"foo_result_notes\", \"roundId\": $(json_uuid "$ID_TournamentRound"), \"player1Id\": $(json_uuid "$ID_Player"), \"player2Id\": $(json_uuid "$ID_Player")}" | extract_id)
echo "Match id=$ID_Match"

# AwardedPrize: create not allowed — using id=1 as placeholder
ID_AwardedPrize=00000000-0000-0000-0000-000000000000
echo "AwardedPrize id=$ID_AwardedPrize"

# TradeDispute: skipped — cannot be created via API
ID_TradeDispute=""
echo "TradeDispute id=skipped"

ID_Game=$(curl -s -X POST "$BASE/games" \
  -H "Content-Type: application/json" \
  -d "{\"gameNumber\": 1, \"winnerSide\": null, \"complexityScore\": 1.0, \"turnsPlayed\": null, \"durationSeconds\": null, \"endedBy\": \"Normal\", \"replayUrl\": \"https://example.com/foo\", \"matchId\": $(json_uuid "$ID_Match"), \"winnerId\": $(json_uuid "$ID_Player")}" | extract_id)
echo "Game id=$ID_Game"
