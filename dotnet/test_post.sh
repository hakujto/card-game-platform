#!/usr/bin/env bash
BASE="http://localhost:5000/api"

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
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"releaseDate\": \"2024-01-01\", \"setType\": \"Core\", \"totalCards\": 1, \"description\": \"foo_description\", \"logoUrl\": \"https://example.com/foo\"}" | extract_id)
echo "CardSet id=$ID_CardSet"

ID_DeckTag=$(curl -s -X POST "$BASE/deck_tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | extract_id)
echo "DeckTag id=$ID_DeckTag"

ID_Player=$(curl -s -X POST "$BASE/players" \
  -H "Content-Type: application/json" \
  -d "{\"displayName\": \"foo_display_name\", \"rank\": \"Bronze\", \"rating\": 1, \"peakRating\": 1, \"bio\": \"foo_bio\", \"countryCode\": \"fo\", \"avatarUrl\": \"https://example.com/foo\", \"preferredFormat\": \"Standard\", \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"lastActiveAt\": \"2024-01-01T00:00:00Z\"}" | extract_id)
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
  -d "{\"name\": \"foo_name\", \"productType\": \"SingleCard\", \"price\": \"1.00\", \"stock\": 1, \"active\": true, \"discountPercent\": 1, \"description\": \"foo_description\", \"imageUrl\": \"https://example.com/foo\", \"featured\": true, \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null'), \"cardSet\": $([ -n "$ID_CardSet" ] && echo '{"id":'"$ID_CardSet"'}' || echo 'null')}" | extract_id)
echo "Product id=$ID_Product"

ID_Coupon=$(curl -s -X POST "$BASE/coupons" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code\", \"discountType\": \"Percent\", \"discountValue\": 1, \"minOrderValue\": \"1.00\", \"maxUses\": null, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00Z\", \"validUntil\": \"2024-01-01T00:00:01Z\", \"isActive\": true}" | extract_id)
echo "Coupon id=$ID_Coupon"

ID_ArticleTag=$(curl -s -X POST "$BASE/article_tags" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | extract_id)
echo "ArticleTag id=$ID_ArticleTag"

ID_Card=$(curl -s -X POST "$BASE/cards" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"cardType\": \"Creature\", \"rarity\": \"Common\", \"manaCost\": 1, \"manaColors\": \"White\", \"attack\": 1, \"defense\": 1, \"loyalty\": 1, \"description\": \"foo_description\", \"flavorText\": \"foo_flavor_text\", \"imageUrl\": \"https://example.com/foo\", \"artistName\": \"foo_artist_name\", \"legalFormats\": \"Standard\", \"isBanned\": false, \"isRestricted\": false, \"powerLevel\": 1, \"set\": $([ -n "$ID_CardSet" ] && echo '{"id":'"$ID_CardSet"'}' || echo 'null')}" | extract_id)
echo "Card id=$ID_Card"

ID_DraftSession=$(curl -s -X POST "$BASE/draft_sessions" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"WaitingForPlayers\", \"draftType\": \"Booster\", \"seats\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"cardSet\": $([ -n "$ID_CardSet" ] && echo '{"id":'"$ID_CardSet"'}' || echo 'null')}" | extract_id)
echo "DraftSession id=$ID_DraftSession"

ID_Deck=$(curl -s -X POST "$BASE/decks" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"isPublic\": true, \"isTournamentLegal\": true, \"archetype\": \"Aggro\", \"wins\": 1, \"losses\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "Deck id=$ID_Deck"

ID_Friendship=$(curl -s -X POST "$BASE/friendships" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"requester\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"receiver\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "Friendship id=$ID_Friendship"

ID_Order=$(curl -s -X POST "$BASE/orders" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"total\": 0, \"discountApplied\": \"0.00\", \"currency\": \"foo\", \"paymentMethod\": \"Card\", \"paymentReference\": \"foo_payment_reference\", \"shippingAddress\": \"foo_shipping_address\", \"trackingNumber\": \"foo_tracking_number\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"paidAt\": \"2024-01-01T00:00:00Z\", \"shippedAt\": \"2024-01-01T00:00:00Z\", \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"coupon\": $([ -n "$ID_Coupon" ] && echo '{"id":'"$ID_Coupon"'}' || echo 'null')}" | extract_id)
echo "Order id=$ID_Order"

ID_Article=$(curl -s -X POST "$BASE/articles" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"coverImageUrl\": \"https://example.com/foo\", \"status\": \"Draft\", \"articleType\": \"Guide\", \"viewCount\": 1, \"publishedAt\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"author\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"featuredDeck\": $([ -n "$ID_Deck" ] && echo '{"id":'"$ID_Deck"'}' || echo 'null')}" | extract_id)
echo "Article id=$ID_Article"

ID_Stream=$(curl -s -X POST "$BASE/streams" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"streamUrl\": \"https://example.com/foo\", \"platform\": \"Twitch\", \"status\": \"Scheduled\", \"viewerCountPeak\": 1, \"scheduledStart\": \"2024-01-01T00:00:00Z\", \"actualStart\": null, \"endedAt\": \"2024-01-01T00:00:00Z\", \"vodUrl\": \"https://example.com/foo\", \"tournament\": $([ -n "$ID_Tournament" ] && echo '{"id":'"$ID_Tournament"'}' || echo 'null'), \"streamer\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "Stream id=$ID_Stream"

ID_PlayerAchievement=$(curl -s -X POST "$BASE/player_achievements" \
  -H "Content-Type: application/json" \
  -d "{\"earnedAt\": \"2024-01-01T00:00:00Z\", \"progress\": 1, \"isCompleted\": true, \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"achievement\": $([ -n "$ID_Achievement" ] && echo '{"id":'"$ID_Achievement"'}' || echo 'null')}" | extract_id)
echo "PlayerAchievement id=$ID_PlayerAchievement"

ID_PlayerSeasonStats=$(curl -s -X POST "$BASE/player_season_statses" \
  -H "Content-Type: application/json" \
  -d "{\"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournamentWins\": 1, \"highestRank\": \"Bronze\", \"seasonPoints\": 1, \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"season\": $([ -n "$ID_Season" ] && echo '{"id":'"$ID_Season"'}' || echo 'null')}" | extract_id)
echo "PlayerSeasonStats id=$ID_PlayerSeasonStats"

ID_Tournament=$(curl -s -X POST "$BASE/tournaments" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"tournamentType\": \"Swiss\", \"status\": \"Draft\", \"maxPlayers\": 2, \"entryFee\": 0, \"prizePool\": 0, \"startTime\": \"2024-01-01T00:00:00Z\", \"endTime\": null, \"isOnline\": true, \"location\": \"foo_location\", \"rulesText\": \"foo_rules_text\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"season\": $([ -n "$ID_Season" ] && echo '{"id":'"$ID_Season"'}' || echo 'null'), \"organizer\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "Tournament id=$ID_Tournament"

ID_CardRuling=$(curl -s -X POST "$BASE/card_rulings" \
  -H "Content-Type: application/json" \
  -d "{\"rulingText\": \"foo_ruling_text\", \"publishedAt\": \"2024-01-01\", \"source\": \"foo_source\", \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "CardRuling id=$ID_CardRuling"

ID_CardAbility=$(curl -s -X POST "$BASE/card_abilities" \
  -H "Content-Type: application/json" \
  -d "{\"abilityType\": \"Keyword\", \"keyword\": \"foo_keyword\", \"abilityText\": \"foo_ability_text\", \"timing\": \"Any\", \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "CardAbility id=$ID_CardAbility"

ID_PlayerCollection=$(curl -s -X POST "$BASE/player_collections" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"Mint\", \"acquiredAt\": \"2024-01-01T00:00:00Z\", \"acquiredVia\": \"Purchase\", \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "PlayerCollection id=$ID_PlayerCollection"

ID_CraftingRecipe=$(curl -s -X POST "$BASE/crafting_recipes" \
  -H "Content-Type: application/json" \
  -d "{\"dustCost\": 1, \"isAvailable\": true, \"resultCard\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "CraftingRecipe id=$ID_CraftingRecipe"

ID_Tradelisting=$(curl -s -X POST "$BASE/tradelistings" \
  -H "Content-Type: application/json" \
  -d "{\"listingType\": \"FixedPrice\", \"askingPrice\": \"1.00\", \"auctionStartPrice\": \"1.00\", \"auctionCurrentBid\": \"1.00\", \"auctionEndTime\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"Mint\", \"quantity\": 1, \"status\": \"Active\", \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"expiresAt\": \"2024-01-01T00:00:00Z\", \"seller\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "Tradelisting id=$ID_Tradelisting"

ID_CardPriceHistory=$(curl -s -X POST "$BASE/card_price_histories" \
  -H "Content-Type: application/json" \
  -d "{\"priceDate\": \"2024-01-01\", \"avgPrice\": \"0.00\", \"minPrice\": \"0.00\", \"maxPrice\": \"1.00\", \"volume\": 1, \"foil\": true, \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "CardPriceHistory id=$ID_CardPriceHistory"

ID_DraftParticipant=$(curl -s -X POST "$BASE/draft_participants" \
  -H "Content-Type: application/json" \
  -d "{\"seatNumber\": 1, \"joinedAt\": \"2024-01-01T00:00:00Z\", \"session\": $([ -n "$ID_DraftSession" ] && echo '{"id":'"$ID_DraftSession"'}' || echo 'null'), \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "DraftParticipant id=$ID_DraftParticipant"

ID_DeckCard=$(curl -s -X POST "$BASE/deck_cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"isCommander\": true, \"deck\": $([ -n "$ID_Deck" ] && echo '{"id":'"$ID_Deck"'}' || echo 'null'), \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "DeckCard id=$ID_DeckCard"

ID_DeckSideboardCard=$(curl -s -X POST "$BASE/deck_sideboard_cards" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deck\": $([ -n "$ID_Deck" ] && echo '{"id":'"$ID_Deck"'}' || echo 'null'), \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "DeckSideboardCard id=$ID_DeckSideboardCard"

ID_DeckTagAssignment=$(curl -s -X POST "$BASE/deck_tag_assignments" \
  -H "Content-Type: application/json" \
  -d "{\"deck\": $([ -n "$ID_Deck" ] && echo '{"id":'"$ID_Deck"'}' || echo 'null'), \"tag\": $([ -n "$ID_DeckTag" ] && echo '{"id":'"$ID_DeckTag"'}' || echo 'null')}" | extract_id)
echo "DeckTagAssignment id=$ID_DeckTagAssignment"

ID_OrderItem=$(curl -s -X POST "$BASE/order_items" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"priceAtPurchase\": 0, \"foil\": true, \"order\": $([ -n "$ID_Order" ] && echo '{"id":'"$ID_Order"'}' || echo 'null'), \"product\": $([ -n "$ID_Product" ] && echo '{"id":'"$ID_Product"'}' || echo 'null')}" | extract_id)
echo "OrderItem id=$ID_OrderItem"

ID_ArticleTagAssignment=$(curl -s -X POST "$BASE/article_tag_assignments" \
  -H "Content-Type: application/json" \
  -d "{\"article\": $([ -n "$ID_Article" ] && echo '{"id":'"$ID_Article"'}' || echo 'null'), \"tag\": $([ -n "$ID_ArticleTag" ] && echo '{"id":'"$ID_ArticleTag"'}' || echo 'null')}" | extract_id)
echo "ArticleTagAssignment id=$ID_ArticleTagAssignment"

ID_ArticleComment=$(curl -s -X POST "$BASE/article_comments" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"isHidden\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"article\": $([ -n "$ID_Article" ] && echo '{"id":'"$ID_Article"'}' || echo 'null'), \"author\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"parentComment\": $([ -n "$ID_ArticleComment" ] && echo '{"id":'"$ID_ArticleComment"'}' || echo 'null')}" | extract_id)
echo "ArticleComment id=$ID_ArticleComment"

ID_TournamentJudge=$(curl -s -X POST "$BASE/tournament_judges" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"HeadJudge\", \"tournament\": $([ -n "$ID_Tournament" ] && echo '{"id":'"$ID_Tournament"'}' || echo 'null'), \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "TournamentJudge id=$ID_TournamentJudge"

ID_TournamentRegistration=$(curl -s -X POST "$BASE/tournament_registrations" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Registered\", \"seed\": 1, \"finalStanding\": 1, \"pointsEarned\": 1, \"registeredAt\": \"2024-01-01T00:00:00Z\", \"tournament\": $([ -n "$ID_Tournament" ] && echo '{"id":'"$ID_Tournament"'}' || echo 'null'), \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"deck\": $([ -n "$ID_Deck" ] && echo '{"id":'"$ID_Deck"'}' || echo 'null')}" | extract_id)
echo "TournamentRegistration id=$ID_TournamentRegistration"

ID_TournamentRound=$(curl -s -X POST "$BASE/tournament_rounds" \
  -H "Content-Type: application/json" \
  -d "{\"roundNumber\": 1, \"status\": \"Pending\", \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": null, \"timeLimitMinutes\": 1, \"tournament\": $([ -n "$ID_Tournament" ] && echo '{"id":'"$ID_Tournament"'}' || echo 'null')}" | extract_id)
echo "TournamentRound id=$ID_TournamentRound"

ID_TournamentPrize=$(curl -s -X POST "$BASE/tournament_prizes" \
  -H "Content-Type: application/json" \
  -d "{\"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"Currency\", \"amount\": 0, \"description\": \"foo_description\", \"packsCount\": 1, \"seasonPoints\": 1, \"tournament\": $([ -n "$ID_Tournament" ] && echo '{"id":'"$ID_Tournament"'}' || echo 'null')}" | extract_id)
echo "TournamentPrize id=$ID_TournamentPrize"

ID_CraftingIngredient=$(curl -s -X POST "$BASE/crafting_ingredients" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipe\": $([ -n "$ID_CraftingRecipe" ] && echo '{"id":'"$ID_CraftingRecipe"'}' || echo 'null'), \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "CraftingIngredient id=$ID_CraftingIngredient"

ID_TradeBid=$(curl -s -X POST "$BASE/trade_bids" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": 1, \"placedAt\": \"2024-01-01T00:00:00Z\", \"isWinning\": true, \"listing\": $([ -n "$ID_Tradelisting" ] && echo '{"id":'"$ID_Tradelisting"'}' || echo 'null'), \"bidder\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "TradeBid id=$ID_TradeBid"

ID_TradeTransaction=$(curl -s -X POST "$BASE/trade_transactions" \
  -H "Content-Type: application/json" \
  -d "{\"finalPrice\": \"1.00\", \"platformFee\": 0, \"status\": \"Pending\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"listing\": $([ -n "$ID_Tradelisting" ] && echo '{"id":'"$ID_Tradelisting"'}' || echo 'null'), \"buyer\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"seller\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "TradeTransaction id=$ID_TradeTransaction"

ID_DraftPick=$(curl -s -X POST "$BASE/draft_picks" \
  -H "Content-Type: application/json" \
  -d "{\"pickNumber\": 1, \"packNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00Z\", \"participant\": $([ -n "$ID_DraftParticipant" ] && echo '{"id":'"$ID_DraftParticipant"'}' || echo 'null'), \"card\": $([ -n "$ID_Card" ] && echo '{"id":'"$ID_Card"'}' || echo 'null')}" | extract_id)
echo "DraftPick id=$ID_DraftPick"

ID_Match=$(curl -s -X POST "$BASE/matches" \
  -H "Content-Type: application/json" \
  -d "{\"tableNumber\": 1, \"status\": \"Pending\", \"player1Wins\": 0, \"player2Wins\": 0, \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"resultNotes\": \"foo_result_notes\", \"round\": $([ -n "$ID_TournamentRound" ] && echo '{"id":'"$ID_TournamentRound"'}' || echo 'null'), \"player1\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"player2\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "Match id=$ID_Match"

ID_AwardedPrize=$(curl -s -X POST "$BASE/awarded_prizes" \
  -H "Content-Type: application/json" \
  -d "{\"finalPlacement\": 1, \"awardedAt\": \"2024-01-01T00:00:00Z\", \"claimed\": true, \"claimedAt\": \"2024-01-01T00:00:00Z\", \"prize\": $([ -n "$ID_TournamentPrize" ] && echo '{"id":'"$ID_TournamentPrize"'}' || echo 'null'), \"player\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "AwardedPrize id=$ID_AwardedPrize"

ID_TradeDispute=$(curl -s -X POST "$BASE/trade_disputes" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"ItemNotReceived\", \"description\": \"foo_description\", \"status\": \"Open\", \"resolution\": \"foo_resolution\", \"openedAt\": \"2024-01-01T00:00:00Z\", \"resolvedAt\": null, \"transaction\": $([ -n "$ID_TradeTransaction" ] && echo '{"id":'"$ID_TradeTransaction"'}' || echo 'null'), \"openedBy\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null'), \"resolvedBy\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "TradeDispute id=$ID_TradeDispute"

ID_Game=$(curl -s -X POST "$BASE/games" \
  -H "Content-Type: application/json" \
  -d "{\"gameNumber\": 1, \"winnerSide\": \"Player1\", \"turnsPlayed\": null, \"durationSeconds\": null, \"endedBy\": \"Normal\", \"replayUrl\": \"https://example.com/foo\", \"match\": $([ -n "$ID_Match" ] && echo '{"id":'"$ID_Match"'}' || echo 'null'), \"winner\": $([ -n "$ID_Player" ] && echo '{"id":'"$ID_Player"'}' || echo 'null')}" | extract_id)
echo "Game id=$ID_Game"
