#!/usr/bin/env bash
BASE="http://localhost:5000/api"

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
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"releaseDate\": \"2024-01-01\", \"rotationDate\": null, \"setType\": \"Core\", \"totalCards\": 1, \"isRotated\": false, \"description\": \"foo_description\", \"logoUrl\": \"https://example.com/foo\"}" | python3 -m json.tool

echo && echo "=== PUT deck_tags/$ID_DeckTag ==="
curl -s -X PUT "$BASE/deck_tags/$ID_DeckTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | python3 -m json.tool

echo && echo "=== PUT players/$ID_Player ==="
curl -s -X PUT "$BASE/players/$ID_Player" \
  -H "Content-Type: application/json" \
  -d "{\"displayName\": \"foo_display_name\", \"rank\": \"Bronze\", \"rating\": 1, \"peakRating\": 1, \"bio\": \"foo_bio\", \"countryCode\": \"fo\", \"avatarUrl\": \"https://example.com/foo\", \"preferredFormat\": \"Standard\", \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"lastActiveAt\": \"2024-01-01T00:00:00Z\"}" | python3 -m json.tool

echo && echo "=== PUT achievements/$ID_Achievement ==="
curl -s -X PUT "$BASE/achievements/$ID_Achievement" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"iconUrl\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"Common\", \"isHidden\": true}" | python3 -m json.tool

echo && echo "=== PUT seasons/$ID_Season ==="
curl -s -X PUT "$BASE/seasons/$ID_Season" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"startDate\": \"2024-01-01\", \"endDate\": \"2024-01-02\", \"format\": \"Standard\", \"isActive\": true, \"rewardDescription\": \"foo_reward_description\"}" | python3 -m json.tool

echo && echo "=== PUT products/$ID_Product ==="
curl -s -X PUT "$BASE/products/$ID_Product" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"productType\": \"SingleCard\", \"price\": 1, \"stock\": 0, \"active\": true, \"discountPercent\": 1, \"description\": \"foo_description\", \"imageUrl\": \"https://example.com/foo\", \"featured\": true, \"cardId\": ${ID_Card:-null}, \"cardSetId\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT coupons/$ID_Coupon ==="
curl -s -X PUT "$BASE/coupons/$ID_Coupon" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code\", \"discountType\": \"Percent\", \"discountValue\": 1, \"minOrderValue\": \"1.00\", \"maxUses\": null, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00Z\", \"validUntil\": \"2024-01-01T00:00:01Z\", \"isActive\": true}" | python3 -m json.tool

echo && echo "=== PUT article_tags/$ID_ArticleTag ==="
curl -s -X PUT "$BASE/article_tags/$ID_ArticleTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | python3 -m json.tool

echo && echo "=== PUT cards/$ID_Card ==="
curl -s -X PUT "$BASE/cards/$ID_Card" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"cardType\": \"Creature\", \"rarity\": \"Common\", \"manaCost\": 1, \"manaColors\": \"White\", \"attack\": 1, \"defense\": 1, \"loyalty\": null, \"description\": \"foo_description\", \"flavorText\": \"foo_flavor_text\", \"imageUrl\": \"https://example.com/foo\", \"artistName\": \"foo_artist_name\", \"legalFormats\": \"Standard\", \"isBanned\": false, \"isRestricted\": false, \"powerLevel\": 1, \"setId\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT draft_sessions/$ID_DraftSession ==="
curl -s -X PUT "$BASE/draft_sessions/$ID_DraftSession" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"WaitingForPlayers\", \"draftType\": \"Booster\", \"seats\": 2, \"createdAt\": \"2024-01-01T00:00:00Z\", \"completedAt\": null, \"cardSetId\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT decks/$ID_Deck ==="
curl -s -X PUT "$BASE/decks/$ID_Deck" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"isPublic\": true, \"isTournamentLegal\": false, \"archetype\": \"Aggro\", \"wins\": 0, \"losses\": 0, \"draws\": 0, \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"playerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT friendships/$ID_Friendship ==="
curl -s -X PUT "$BASE/friendships/$ID_Friendship" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"requesterId\": ${ID_Player:-null}, \"receiverId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT orders/$ID_Order ==="
curl -s -X PUT "$BASE/orders/$ID_Order" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"total\": 0, \"discountApplied\": \"0.00\", \"currency\": \"foo\", \"paymentMethod\": \"Card\", \"paymentReference\": \"foo_payment_reference\", \"shippingAddress\": \"foo_shipping_address\", \"trackingNumber\": \"foo_tracking_number\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"paidAt\": \"2024-01-01T00:00:00Z\", \"shippedAt\": null, \"playerId\": ${ID_Player:-null}, \"couponId\": ${ID_Coupon:-null}}" | python3 -m json.tool

echo && echo "=== PUT articles/$ID_Article ==="
curl -s -X PUT "$BASE/articles/$ID_Article" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"coverImageUrl\": \"https://example.com/foo\", \"status\": \"Draft\", \"articleType\": \"Guide\", \"viewCount\": 0, \"publishedAt\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"authorId\": ${ID_Player:-null}, \"featuredDeckId\": ${ID_Deck:-null}}" | python3 -m json.tool

echo && echo "=== PUT streams/$ID_Stream ==="
curl -s -X PUT "$BASE/streams/$ID_Stream" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"streamUrl\": \"https://example.com/foo\", \"platform\": \"Twitch\", \"status\": \"Scheduled\", \"viewerCountPeak\": 0, \"scheduledStart\": \"2024-01-01T00:00:00Z\", \"actualStart\": null, \"endedAt\": null, \"vodUrl\": \"https://example.com/foo\", \"tournamentId\": ${ID_Tournament:-null}, \"streamerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT player_achievements/$ID_PlayerAchievement ==="
curl -s -X PUT "$BASE/player_achievements/$ID_PlayerAchievement" \
  -H "Content-Type: application/json" \
  -d "{\"earnedAt\": \"2024-01-01T00:00:00Z\", \"progress\": 0, \"isCompleted\": false, \"playerId\": ${ID_Player:-null}, \"achievementId\": ${ID_Achievement:-null}}" | python3 -m json.tool

echo && echo "=== PUT player_season_statses/$ID_PlayerSeasonStats ==="
curl -s -X PUT "$BASE/player_season_statses/$ID_PlayerSeasonStats" \
  -H "Content-Type: application/json" \
  -d "{\"wins\": 0, \"losses\": 0, \"draws\": 1, \"tournamentWins\": 0, \"highestRank\": \"Bronze\", \"seasonPoints\": 0, \"playerId\": ${ID_Player:-null}, \"seasonId\": ${ID_Season:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournaments/$ID_Tournament ==="
curl -s -X PUT "$BASE/tournaments/$ID_Tournament" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"tournamentType\": \"Swiss\", \"status\": \"Draft\", \"maxPlayers\": 2, \"entryFee\": 0, \"prizePool\": 0, \"startTime\": \"2024-01-01T00:00:00Z\", \"endTime\": null, \"isOnline\": true, \"location\": \"foo_location\", \"rulesText\": \"foo_rules_text\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"seasonId\": ${ID_Season:-null}, \"organizerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT card_rulings/$ID_CardRuling ==="
curl -s -X PUT "$BASE/card_rulings/$ID_CardRuling" \
  -H "Content-Type: application/json" \
  -d "{\"rulingText\": \"foo_ruling_text\", \"publishedAt\": \"2024-01-01\", \"source\": \"foo_source\", \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT card_abilities/$ID_CardAbility ==="
curl -s -X PUT "$BASE/card_abilities/$ID_CardAbility" \
  -H "Content-Type: application/json" \
  -d "{\"abilityType\": \"Keyword\", \"keyword\": \"foo_keyword\", \"abilityText\": \"foo_ability_text\", \"timing\": \"Any\", \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT player_collections/$ID_PlayerCollection ==="
curl -s -X PUT "$BASE/player_collections/$ID_PlayerCollection" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"Mint\", \"acquiredAt\": \"2024-01-01T00:00:00Z\", \"acquiredVia\": \"Purchase\", \"playerId\": ${ID_Player:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT crafting_recipes/$ID_CraftingRecipe ==="
curl -s -X PUT "$BASE/crafting_recipes/$ID_CraftingRecipe" \
  -H "Content-Type: application/json" \
  -d "{\"dustCost\": 1, \"isAvailable\": true, \"resultCardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT trade_listings/$ID_TradeListing ==="
curl -s -X PUT "$BASE/trade_listings/$ID_TradeListing" \
  -H "Content-Type: application/json" \
  -d "{\"listingType\": \"FixedPrice\", \"askingPrice\": \"1.00\", \"auctionStartPrice\": \"1.00\", \"auctionCurrentBid\": \"1.00\", \"auctionEndTime\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"Mint\", \"quantity\": 1, \"status\": \"Active\", \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"expiresAt\": \"2024-01-01T00:00:00Z\", \"sellerId\": ${ID_Player:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT card_price_histories/$ID_CardPriceHistory ==="
curl -s -X PUT "$BASE/card_price_histories/$ID_CardPriceHistory" \
  -H "Content-Type: application/json" \
  -d "{\"priceDate\": \"2024-01-01\", \"avgPrice\": \"0.00\", \"minPrice\": 0, \"maxPrice\": \"1.00\", \"volume\": 0, \"foil\": true, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT draft_participants/$ID_DraftParticipant ==="
curl -s -X PUT "$BASE/draft_participants/$ID_DraftParticipant" \
  -H "Content-Type: application/json" \
  -d "{\"seatNumber\": 1, \"joinedAt\": \"2024-01-01T00:00:00Z\", \"sessionId\": ${ID_DraftSession:-null}, \"playerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT deck_cards/$ID_DeckCard ==="
curl -s -X PUT "$BASE/deck_cards/$ID_DeckCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"isCommander\": true, \"deckId\": ${ID_Deck:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X PUT "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deckId\": ${ID_Deck:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s -X PUT "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" \
  -H "Content-Type: application/json" \
  -d "{\"deckId\": ${ID_Deck:-null}, \"tagId\": ${ID_DeckTag:-null}}" | python3 -m json.tool

echo && echo "=== PUT order_items/$ID_OrderItem ==="
curl -s -X PUT "$BASE/order_items/$ID_OrderItem" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"priceAtPurchase\": 0, \"foil\": true, \"orderId\": ${ID_Order:-null}, \"productId\": ${ID_Product:-null}}" | python3 -m json.tool

echo && echo "=== PUT article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s -X PUT "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" \
  -H "Content-Type: application/json" \
  -d "{\"articleId\": ${ID_Article:-null}, \"tagId\": ${ID_ArticleTag:-null}}" | python3 -m json.tool

echo && echo "=== PUT article_comments/$ID_ArticleComment ==="
curl -s -X PUT "$BASE/article_comments/$ID_ArticleComment" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"isHidden\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"articleId\": ${ID_Article:-null}, \"authorId\": ${ID_Player:-null}, \"parentCommentId\": ${ID_ArticleComment:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournament_judges/$ID_TournamentJudge ==="
curl -s -X PUT "$BASE/tournament_judges/$ID_TournamentJudge" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"HeadJudge\", \"tournamentId\": ${ID_Tournament:-null}, \"playerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournament_registrations/$ID_TournamentRegistration ==="
curl -s -X PUT "$BASE/tournament_registrations/$ID_TournamentRegistration" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Registered\", \"seed\": null, \"finalStanding\": null, \"pointsEarned\": 0, \"registeredAt\": \"2024-01-01T00:00:00Z\", \"tournamentId\": ${ID_Tournament:-null}, \"playerId\": ${ID_Player:-null}, \"deckId\": ${ID_Deck:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournament_rounds/$ID_TournamentRound ==="
curl -s -X PUT "$BASE/tournament_rounds/$ID_TournamentRound" \
  -H "Content-Type: application/json" \
  -d "{\"roundNumber\": 1, \"status\": \"Pending\", \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": null, \"timeLimitMinutes\": 1, \"tournamentId\": ${ID_Tournament:-null}}" | python3 -m json.tool

echo && echo "=== PUT tournament_prizes/$ID_TournamentPrize ==="
curl -s -X PUT "$BASE/tournament_prizes/$ID_TournamentPrize" \
  -H "Content-Type: application/json" \
  -d "{\"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"Currency\", \"amount\": 0, \"description\": \"foo_description\", \"packsCount\": 1, \"seasonPoints\": 1, \"tournamentId\": ${ID_Tournament:-null}}" | python3 -m json.tool

echo && echo "=== PUT crafting_ingredients/$ID_CraftingIngredient ==="
curl -s -X PUT "$BASE/crafting_ingredients/$ID_CraftingIngredient" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipeId\": ${ID_CraftingRecipe:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT trade_bids/$ID_TradeBid ==="
curl -s -X PUT "$BASE/trade_bids/$ID_TradeBid" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": 1, \"placedAt\": \"2024-01-01T00:00:00Z\", \"isWinning\": true, \"listingId\": ${ID_TradeListing:-null}, \"bidderId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT trade_transactions/$ID_TradeTransaction ==="
curl -s -X PUT "$BASE/trade_transactions/$ID_TradeTransaction" \
  -H "Content-Type: application/json" \
  -d "{\"finalPrice\": 1, \"platformFee\": 0, \"status\": \"Pending\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"listingId\": ${ID_TradeListing:-null}, \"buyerId\": ${ID_Player:-null}, \"sellerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT draft_picks/$ID_DraftPick ==="
curl -s -X PUT "$BASE/draft_picks/$ID_DraftPick" \
  -H "Content-Type: application/json" \
  -d "{\"pickNumber\": 1, \"packNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00Z\", \"participantId\": ${ID_DraftParticipant:-null}, \"cardId\": ${ID_Card:-null}}" | python3 -m json.tool

echo && echo "=== PUT matches/$ID_Match ==="
curl -s -X PUT "$BASE/matches/$ID_Match" \
  -H "Content-Type: application/json" \
  -d "{\"tableNumber\": 1, \"status\": \"Pending\", \"player1Wins\": 0, \"player2Wins\": 0, \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": null, \"resultNotes\": \"foo_result_notes\", \"roundId\": ${ID_TournamentRound:-null}, \"player1Id\": ${ID_Player:-null}, \"player2Id\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT awarded_prizes/$ID_AwardedPrize ==="
curl -s -X PUT "$BASE/awarded_prizes/$ID_AwardedPrize" \
  -H "Content-Type: application/json" \
  -d "{\"finalPlacement\": 1, \"awardedAt\": \"2024-01-01T00:00:00Z\", \"claimed\": false, \"claimedAt\": \"2024-01-01T00:00:00Z\", \"prizeId\": ${ID_TournamentPrize:-null}, \"playerId\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT trade_disputes/$ID_TradeDispute ==="
curl -s -X PUT "$BASE/trade_disputes/$ID_TradeDispute" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"ItemNotReceived\", \"description\": \"foo_description\", \"status\": \"Open\", \"resolution\": \"foo_resolution\", \"openedAt\": \"2024-01-01T00:00:00Z\", \"resolvedAt\": null, \"transactionId\": ${ID_TradeTransaction:-null}, \"openedById\": ${ID_Player:-null}, \"resolvedById\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT games/$ID_Game ==="
curl -s -X PUT "$BASE/games/$ID_Game" \
  -H "Content-Type: application/json" \
  -d "{\"gameNumber\": 1, \"winnerSide\": null, \"turnsPlayed\": null, \"durationSeconds\": null, \"endedBy\": \"Normal\", \"replayUrl\": \"https://example.com/foo\", \"matchId\": ${ID_Match:-null}, \"winnerId\": ${ID_Player:-null}}" | python3 -m json.tool
