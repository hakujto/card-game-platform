#!/usr/bin/env bash
BASE="http://localhost:8080/api"

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
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"releaseDate\": \"2024-01-01\", \"setType\": \"CORE\", \"totalCards\": 1, \"description\": \"foo_description\", \"logoUrl\": \"https://example.com/foo\"}" | extract_id)
echo "CardSet id=$ID_CardSet"

ID_DeckTag=$(curl -s -X POST "$BASE/deck_tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | extract_id)
echo "DeckTag id=$ID_DeckTag"

ID_Achievement=$(curl -s -X POST "$BASE/achievements" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"iconUrl\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"COMMON\", \"isHidden\": true}" | extract_id)
echo "Achievement id=$ID_Achievement"

ID_Season=$(curl -s -X POST "$BASE/seasons" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"startDate\": \"2024-01-01\", \"endDate\": \"2024-01-01\", \"format\": \"STANDARD\", \"isActive\": true, \"rewardDescription\": \"foo_reward_description\"}" | extract_id)
echo "Season id=$ID_Season"

ID_Product=$(curl -s -X POST "$BASE/products" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"productType\": \"SINGLECARD\", \"price\": \"1.00\", \"stock\": 1, \"active\": true, \"discountPercent\": 1, \"description\": \"foo_description\", \"imageUrl\": \"https://example.com/foo\", \"featured\": true, \"card_id\": ${ID_Card:-null}, \"card_set_id\": ${ID_CardSet:-null}}" | extract_id)
echo "Product id=$ID_Product"

ID_Coupon=$(curl -s -X POST "$BASE/coupons" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code\", \"discountType\": \"PERCENT\", \"discountValue\": \"1.00\", \"minOrderValue\": \"1.00\", \"maxUses\": 1, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00Z\", \"validUntil\": \"2024-01-01T00:00:00Z\", \"isActive\": true}" | extract_id)
echo "Coupon id=$ID_Coupon"

ID_ArticleTag=$(curl -s -X POST "$BASE/article_tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | extract_id)
echo "ArticleTag id=$ID_ArticleTag"

ID_Card=$(curl -s -X POST "$BASE/cards" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"cardType\": \"CREATURE\", \"rarity\": \"COMMON\", \"manaCost\": 1, \"manaColors\": \"WHITE\", \"attack\": 1, \"defense\": 1, \"loyalty\": 1, \"description\": \"foo_description\", \"flavorText\": \"foo_flavor_text\", \"imageUrl\": \"https://example.com/foo\", \"artistName\": \"foo_artist_name\", \"legalFormats\": \"STANDARD\", \"isBanned\": true, \"isRestricted\": true, \"powerLevel\": 1, \"set_id\": $ID_CardSet}" | extract_id)
echo "Card id=$ID_Card"

ID_PlayerSeasonStats=$(curl -s -X POST "$BASE/player_season_statses" \
  -H "Content-Type: application/json" \
  -d "{\"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournamentWins\": 1, \"highestRank\": \"BRONZE\", \"seasonPoints\": 1, \"season_id\": $ID_Season}" | extract_id)
echo "PlayerSeasonStats id=$ID_PlayerSeasonStats"

ID_OrderItem=$(curl -s -X POST "$BASE/order_items" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"priceAtPurchase\": \"1.00\", \"foil\": true, \"product_id\": $ID_Product}" | extract_id)
echo "OrderItem id=$ID_OrderItem"

ID_CardRuling=$(curl -s -X POST "$BASE/card_rulings" \
  -H "Content-Type: application/json" \
  -d "{\"rulingText\": \"foo_ruling_text\", \"publishedAt\": \"2024-01-01\", \"source\": \"foo_source\", \"card_id\": $ID_Card}" | extract_id)
echo "CardRuling id=$ID_CardRuling"

ID_CardAbility=$(curl -s -X POST "$BASE/card_abilities" \
  -H "Content-Type: application/json" \
  -d "{\"abilityType\": \"KEYWORD\", \"keyword\": \"foo_keyword\", \"abilityText\": \"foo_ability_text\", \"timing\": \"ANY\", \"card_id\": $ID_Card}" | extract_id)
echo "CardAbility id=$ID_CardAbility"

ID_CraftingRecipe=$(curl -s -X POST "$BASE/crafting_recipes" \
  -H "Content-Type: application/json" \
  -d "{\"dustCost\": 1, \"isAvailable\": true, \"result_card_id\": $ID_Card}" | extract_id)
echo "CraftingRecipe id=$ID_CraftingRecipe"

ID_CardPriceHistory=$(curl -s -X POST "$BASE/card_price_histories" \
  -H "Content-Type: application/json" \
  -d "{\"priceDate\": \"2024-01-01\", \"avgPrice\": \"1.00\", \"minPrice\": \"1.00\", \"maxPrice\": \"1.00\", \"volume\": 1, \"foil\": true, \"card_id\": $ID_Card}" | extract_id)
echo "CardPriceHistory id=$ID_CardPriceHistory"

ID_Player=$(curl -s -X POST "$BASE/players" \
  -H "Content-Type: application/json" \
  -d "{\"displayName\": \"foo_display_name\", \"rank\": \"BRONZE\", \"rating\": 1, \"peakRating\": 1, \"bio\": \"foo_bio\", \"countryCode\": \"fo\", \"avatarUrl\": \"https://example.com/foo\", \"preferredFormat\": \"STANDARD\", \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"lastActiveAt\": \"2024-01-01T00:00:00Z\", \"season_stats_id\": $ID_PlayerSeasonStats}" | extract_id)
echo "Player id=$ID_Player"

ID_CraftingIngredient=$(curl -s -X POST "$BASE/crafting_ingredients" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipe_id\": $ID_CraftingRecipe, \"card_id\": $ID_Card}" | extract_id)
echo "CraftingIngredient id=$ID_CraftingIngredient"

ID_Deck=$(curl -s -X POST "$BASE/decks" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"STANDARD\", \"isPublic\": true, \"isTournamentLegal\": true, \"archetype\": \"AGGRO\", \"wins\": 1, \"losses\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | extract_id)
echo "Deck id=$ID_Deck"

ID_PlayerCollection=$(curl -s -X POST "$BASE/player_collections" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"MINT\", \"acquiredAt\": \"2024-01-01T00:00:00Z\", \"acquiredVia\": \"PURCHASE\", \"player_id\": $ID_Player, \"card_id\": $ID_Card}" | extract_id)
echo "PlayerCollection id=$ID_PlayerCollection"

ID_Friendship=$(curl -s -X POST "$BASE/friendships" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"PENDING\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"requester_id\": $ID_Player, \"receiver_id\": $ID_Player}" | extract_id)
echo "Friendship id=$ID_Friendship"

ID_PlayerAchievement=$(curl -s -X POST "$BASE/player_achievements" \
  -H "Content-Type: application/json" \
  -d "{\"earnedAt\": \"2024-01-01T00:00:00Z\", \"progress\": 1, \"isCompleted\": true, \"player_id\": $ID_Player, \"achievement_id\": $ID_Achievement}" | extract_id)
echo "PlayerAchievement id=$ID_PlayerAchievement"

ID_Tournament=$(curl -s -X POST "$BASE/tournaments" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"STANDARD\", \"tournamentType\": \"SWISS\", \"status\": \"DRAFT\", \"maxPlayers\": 1, \"entryFee\": \"1.00\", \"prizePool\": \"1.00\", \"startTime\": \"2024-01-01T00:00:00Z\", \"endTime\": \"2024-01-01T00:00:00Z\", \"isOnline\": true, \"location\": \"foo_location\", \"rulesText\": \"foo_rules_text\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"season_id\": $ID_Season, \"organizer_id\": $ID_Player}" | extract_id)
echo "Tournament id=$ID_Tournament"

ID_Match=$(curl -s -X POST "$BASE/matches" \
  -H "Content-Type: application/json" \
  -d "{\"tableNumber\": 1, \"status\": \"PENDING\", \"player1Wins\": 1, \"player2Wins\": 1, \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"resultNotes\": \"foo_result_notes\", \"player1_id\": $ID_Player, \"player2_id\": ${ID_Player:-null}}" | extract_id)
echo "Match id=$ID_Match"

ID_Order=$(curl -s -X POST "$BASE/orders" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"PENDING\", \"total\": \"1.00\", \"discountApplied\": \"1.00\", \"currency\": \"foo\", \"paymentMethod\": \"CARD\", \"paymentReference\": \"foo_payment_reference\", \"shippingAddress\": \"foo_shipping_address\", \"trackingNumber\": \"foo_tracking_number\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"paidAt\": \"2024-01-01T00:00:00Z\", \"shippedAt\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player, \"items_id\": $ID_OrderItem, \"coupon_id\": ${ID_Coupon:-null}}" | extract_id)
echo "Order id=$ID_Order"

ID_Tradelisting=$(curl -s -X POST "$BASE/tradelistings" \
  -H "Content-Type: application/json" \
  -d "{\"listingType\": \"FIXEDPRICE\", \"askingPrice\": \"1.00\", \"auctionStartPrice\": \"1.00\", \"auctionCurrentBid\": \"1.00\", \"auctionEndTime\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"MINT\", \"quantity\": 1, \"status\": \"ACTIVE\", \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"expiresAt\": \"2024-01-01T00:00:00Z\", \"seller_id\": $ID_Player, \"card_id\": $ID_Card}" | extract_id)
echo "Tradelisting id=$ID_Tradelisting"

ID_DraftParticipant=$(curl -s -X POST "$BASE/draft_participants" \
  -H "Content-Type: application/json" \
  -d "{\"seatNumber\": 1, \"joinedAt\": \"2024-01-01T00:00:00Z\", \"player_id\": $ID_Player}" | extract_id)
echo "DraftParticipant id=$ID_DraftParticipant"

ID_ArticleComment=$(curl -s -X POST "$BASE/article_comments" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"isHidden\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"parent_comment_id\": ${ID_ArticleComment:-null}}" | extract_id)
echo "ArticleComment id=$ID_ArticleComment"

ID_Stream=$(curl -s -X POST "$BASE/streams" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"streamUrl\": \"https://example.com/foo\", \"platform\": \"TWITCH\", \"status\": \"SCHEDULED\", \"viewerCountPeak\": 1, \"scheduledStart\": \"2024-01-01T00:00:00Z\", \"actualStart\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"vodUrl\": \"https://example.com/foo\", \"tournament_id\": ${ID_Tournament:-null}, \"streamer_id\": $ID_Player}" | extract_id)
echo "Stream id=$ID_Stream"

ID_DeckCard=$(curl -s -X POST "$BASE/deck_cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"isCommander\": true, \"deck_id\": $ID_Deck, \"card_id\": $ID_Card}" | extract_id)
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
  -d "{\"role\": \"HEADJUDGE\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player}" | extract_id)
echo "TournamentJudge id=$ID_TournamentJudge"

ID_TournamentRegistration=$(curl -s -X POST "$BASE/tournament_registrations" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"REGISTERED\", \"seed\": 1, \"finalStanding\": 1, \"pointsEarned\": 1, \"registeredAt\": \"2024-01-01T00:00:00Z\", \"tournament_id\": $ID_Tournament, \"player_id\": $ID_Player, \"deck_id\": $ID_Deck}" | extract_id)
echo "TournamentRegistration id=$ID_TournamentRegistration"

ID_TournamentPrize=$(curl -s -X POST "$BASE/tournament_prizes" \
  -H "Content-Type: application/json" \
  -d "{\"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"CURRENCY\", \"amount\": \"1.00\", \"description\": \"foo_description\", \"packsCount\": 1, \"seasonPoints\": 1, \"tournament_id\": $ID_Tournament}" | extract_id)
echo "TournamentPrize id=$ID_TournamentPrize"

ID_TournamentRound=$(curl -s -X POST "$BASE/tournament_rounds" \
  -H "Content-Type: application/json" \
  -d "{\"roundNumber\": 1, \"status\": \"PENDING\", \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"timeLimitMinutes\": 1, \"tournament_id\": $ID_Tournament, \"matches_id\": $ID_Match}" | extract_id)
echo "TournamentRound id=$ID_TournamentRound"

ID_Game=$(curl -s -X POST "$BASE/games" \
  -H "Content-Type: application/json" \
  -d "{\"gameNumber\": 1, \"winnerSide\": \"PLAYER1\", \"turnsPlayed\": 1, \"durationSeconds\": 1, \"endedBy\": \"NORMAL\", \"replayUrl\": \"https://example.com/foo\", \"match_id\": $ID_Match, \"winner_id\": ${ID_Player:-null}}" | extract_id)
echo "Game id=$ID_Game"

ID_TradeBid=$(curl -s -X POST "$BASE/trade_bids" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": \"1.00\", \"placedAt\": \"2024-01-01T00:00:00Z\", \"isWinning\": true, \"listing_id\": $ID_Tradelisting, \"bidder_id\": $ID_Player}" | extract_id)
echo "TradeBid id=$ID_TradeBid"

ID_TradeTransaction=$(curl -s -X POST "$BASE/trade_transactions" \
  -H "Content-Type: application/json" \
  -d "{\"finalPrice\": \"1.00\", \"platformFee\": \"1.00\", \"status\": \"PENDING\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"listing_id\": $ID_Tradelisting, \"buyer_id\": $ID_Player, \"seller_id\": $ID_Player}" | extract_id)
echo "TradeTransaction id=$ID_TradeTransaction"

ID_DraftSession=$(curl -s -X POST "$BASE/draft_sessions" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"WAITINGFORPLAYERS\", \"draftType\": \"BOOSTER\", \"seats\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"card_set_id\": $ID_CardSet, \"participants_id\": $ID_DraftParticipant}" | extract_id)
echo "DraftSession id=$ID_DraftSession"

ID_DraftPick=$(curl -s -X POST "$BASE/draft_picks" \
  -H "Content-Type: application/json" \
  -d "{\"pickNumber\": 1, \"packNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00Z\", \"participant_id\": $ID_DraftParticipant, \"card_id\": $ID_Card}" | extract_id)
echo "DraftPick id=$ID_DraftPick"

ID_Article=$(curl -s -X POST "$BASE/articles" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"coverImageUrl\": \"https://example.com/foo\", \"status\": \"DRAFT\", \"articleType\": \"GUIDE\", \"viewCount\": 1, \"publishedAt\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"author_id\": $ID_Player, \"featured_deck_id\": ${ID_Deck:-null}, \"comments_id\": $ID_ArticleComment}" | extract_id)
echo "Article id=$ID_Article"

ID_AwardedPrize=$(curl -s -X POST "$BASE/awarded_prizes" \
  -H "Content-Type: application/json" \
  -d "{\"finalPlacement\": 1, \"awardedAt\": \"2024-01-01T00:00:00Z\", \"claimed\": true, \"claimedAt\": \"2024-01-01T00:00:00Z\", \"prize_id\": $ID_TournamentPrize, \"player_id\": $ID_Player}" | extract_id)
echo "AwardedPrize id=$ID_AwardedPrize"

ID_TradeDispute=$(curl -s -X POST "$BASE/trade_disputes" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"ITEMNOTRECEIVED\", \"description\": \"foo_description\", \"status\": \"OPEN\", \"resolution\": \"foo_resolution\", \"openedAt\": \"2024-01-01T00:00:00Z\", \"resolvedAt\": \"2024-01-01T00:00:00Z\", \"transaction_id\": $ID_TradeTransaction, \"opened_by_id\": $ID_Player, \"resolved_by_id\": ${ID_Player:-null}}" | extract_id)
echo "TradeDispute id=$ID_TradeDispute"

ID_ArticleTagAssignment=$(curl -s -X POST "$BASE/article_tag_assignments" \
  -H "Content-Type: application/json" \
  -d "{\"article_id\": $ID_Article, \"tag_id\": $ID_ArticleTag}" | extract_id)
echo "ArticleTagAssignment id=$ID_ArticleTagAssignment"
