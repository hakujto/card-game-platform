#!/usr/bin/env bash
BASE="http://localhost:8000/api"

ID_CardSet=1
ID_DeckTag=1
ID_Achievement=1
ID_Season=1
ID_Product=1
ID_Coupon=1
ID_ArticleTag=1
ID_TopUpPackage=1
ID_FeatureFlag=1
ID_SystemAnnouncement=1
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
ID_ContentLike=1
ID_Bookmark=1
ID_Notification=1
ID_NotificationPreference=1
ID_PushDevice=1
ID_Message=1
ID_PlayerReport=1
ID_ModerationAction=1
ID_ContentReport=1
ID_Wallet=1
ID_TopUpOrder=1
ID_LeaderboardEntry=1
ID_AuditLog=1
ID_PlatformConfig=1
ID_DeckCard=1
ID_DeckSideboardCard=1
ID_DeckTagAssignment=1
ID_DeckReview=1
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
ID_Conversation=1
ID_WalletTransaction=1
ID_LeaderboardSnapshot=1
ID_AwardedPrize=1
ID_TradeDispute=1
ID_ArticleTagAssignment=1

echo && echo "=== PUT card_sets/$ID_CardSet ==="
curl -s -X PUT "$BASE/card_sets/$ID_CardSet" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"code\": \"foo_code\", \"releaseDate\": \"2024-01-01\", \"setType\": \"Core\", \"totalCards\": 1, \"description\": \"foo_description\", \"logoUrl\": \"https://example.com/foo\"}" | python3 -m json.tool

echo && echo "=== PUT deck_tags/$ID_DeckTag ==="
curl -s -X PUT "$BASE/deck_tags/$ID_DeckTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"color\": \"foo_col\"}" | python3 -m json.tool

echo && echo "=== PUT achievements/$ID_Achievement ==="
curl -s -X PUT "$BASE/achievements/$ID_Achievement" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"iconUrl\": \"https://example.com/foo\", \"points\": 1, \"rarity\": \"Common\", \"isHidden\": true}" | python3 -m json.tool

echo && echo "=== PUT seasons/$ID_Season ==="
curl -s -X PUT "$BASE/seasons/$ID_Season" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"startDate\": \"2024-01-01\", \"endDate\": \"2024-01-01\", \"format\": \"Standard\", \"isActive\": true, \"rewardDescription\": \"foo_reward_description\"}" | python3 -m json.tool

echo && echo "=== PUT products/$ID_Product ==="
curl -s -X PUT "$BASE/products/$ID_Product" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"productType\": \"SingleCard\", \"price\": \"1.00\", \"stock\": 1, \"active\": true, \"discountPercent\": 1, \"description\": \"foo_description\", \"imageUrl\": \"https://example.com/foo\", \"featured\": true, \"card\": ${ID_Card:-null}, \"cardSet\": ${ID_CardSet:-null}}" | python3 -m json.tool

echo && echo "=== PUT coupons/$ID_Coupon ==="
curl -s -X PUT "$BASE/coupons/$ID_Coupon" \
  -H "Content-Type: application/json" \
  -d "{\"code\": \"foo_code\", \"discountType\": \"Percent\", \"discountValue\": \"1.00\", \"minOrderValue\": \"1.00\", \"maxUses\": 1, \"usesCount\": 1, \"validFrom\": \"2024-01-01T00:00:00Z\", \"validUntil\": \"2024-01-01T00:00:00Z\", \"isActive\": true}" | python3 -m json.tool

echo && echo "=== PUT article_tags/$ID_ArticleTag ==="
curl -s -X PUT "$BASE/article_tags/$ID_ArticleTag" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"slug\": \"foo_slug\"}" | python3 -m json.tool

echo && echo "=== PUT top_up_packages/$ID_TopUpPackage ==="
curl -s -X PUT "$BASE/top_up_packages/$ID_TopUpPackage" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"price\": \"1.00\", \"currency\": \"foo\", \"creditsAmount\": \"1.00\", \"gemsAmount\": 1, \"bonusPercent\": 1, \"isActive\": true, \"featured\": true}" | python3 -m json.tool

echo && echo "=== PUT feature_flags/$ID_FeatureFlag ==="
curl -s -X PUT "$BASE/feature_flags/$ID_FeatureFlag" \
  -H "Content-Type: application/json" \
  -d "{\"key\": \"foo_key\", \"isEnabled\": true, \"rolloutPercent\": 1, \"description\": \"foo_description\", \"updatedAt\": \"2024-01-01T00:00:00Z\"}" | python3 -m json.tool

echo && echo "=== PUT system_announcements/$ID_SystemAnnouncement ==="
curl -s -X PUT "$BASE/system_announcements/$ID_SystemAnnouncement" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"body\": \"foo_body\", \"announcementType\": \"Maintenance\", \"severity\": \"Info\", \"isActive\": true, \"showFrom\": \"2024-01-01T00:00:00Z\", \"showUntil\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\"}" | python3 -m json.tool

echo && echo "=== PUT cards/$ID_Card ==="
curl -s -X PUT "$BASE/cards/$ID_Card" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"cardType\": \"Creature\", \"rarity\": \"Common\", \"manaCost\": 1, \"manaColors\": \"White\", \"attack\": 1, \"defense\": 1, \"loyalty\": 1, \"description\": \"foo_description\", \"flavorText\": \"foo_flavor_text\", \"imageUrl\": \"https://example.com/foo\", \"artistName\": \"foo_artist_name\", \"legalFormats\": \"Standard\", \"isBanned\": true, \"isRestricted\": true, \"powerLevel\": 1, \"set\": $ID_CardSet}" | python3 -m json.tool

echo && echo "=== PUT player_season_statses/$ID_PlayerSeasonStats ==="
curl -s -X PUT "$BASE/player_season_statses/$ID_PlayerSeasonStats" \
  -H "Content-Type: application/json" \
  -d "{\"wins\": 1, \"losses\": 1, \"draws\": 1, \"tournamentWins\": 1, \"highestRank\": \"Bronze\", \"seasonPoints\": 1, \"season\": $ID_Season}" | python3 -m json.tool

echo && echo "=== PUT order_items/$ID_OrderItem ==="
curl -s -X PUT "$BASE/order_items/$ID_OrderItem" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"priceAtPurchase\": \"1.00\", \"foil\": true, \"product\": $ID_Product}" | python3 -m json.tool

echo && echo "=== PUT card_rulings/$ID_CardRuling ==="
curl -s -X PUT "$BASE/card_rulings/$ID_CardRuling" \
  -H "Content-Type: application/json" \
  -d "{\"rulingText\": \"foo_ruling_text\", \"publishedAt\": \"2024-01-01\", \"source\": \"foo_source\", \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT card_abilities/$ID_CardAbility ==="
curl -s -X PUT "$BASE/card_abilities/$ID_CardAbility" \
  -H "Content-Type: application/json" \
  -d "{\"abilityType\": \"Keyword\", \"keyword\": \"foo_keyword\", \"abilityText\": \"foo_ability_text\", \"timing\": \"Any\", \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT crafting_recipes/$ID_CraftingRecipe ==="
curl -s -X PUT "$BASE/crafting_recipes/$ID_CraftingRecipe" \
  -H "Content-Type: application/json" \
  -d "{\"dustCost\": 1, \"isAvailable\": true, \"resultCard\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT card_price_histories/$ID_CardPriceHistory ==="
curl -s -X PUT "$BASE/card_price_histories/$ID_CardPriceHistory" \
  -H "Content-Type: application/json" \
  -d "{\"priceDate\": \"2024-01-01\", \"avgPrice\": \"1.00\", \"minPrice\": \"1.00\", \"maxPrice\": \"1.00\", \"volume\": 1, \"foil\": true, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT players/$ID_Player ==="
curl -s -X PUT "$BASE/players/$ID_Player" \
  -H "Content-Type: application/json" \
  -d "{\"displayName\": \"foo_display_name\", \"rank\": \"Bronze\", \"rating\": 1, \"peakRating\": 1, \"bio\": \"foo_bio\", \"countryCode\": \"fo\", \"avatarUrl\": \"https://example.com/foo\", \"preferredFormat\": \"Standard\", \"isVerified\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"lastActiveAt\": \"2024-01-01T00:00:00Z\", \"seasonStats\": $ID_PlayerSeasonStats}" | python3 -m json.tool

echo && echo "=== PUT crafting_ingredients/$ID_CraftingIngredient ==="
curl -s -X PUT "$BASE/crafting_ingredients/$ID_CraftingIngredient" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"recipe\": $ID_CraftingRecipe, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT decks/$ID_Deck ==="
curl -s -X PUT "$BASE/decks/$ID_Deck" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"isPublic\": true, \"isTournamentLegal\": true, \"archetype\": \"Aggro\", \"wins\": 1, \"losses\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT player_collections/$ID_PlayerCollection ==="
curl -s -X PUT "$BASE/player_collections/$ID_PlayerCollection" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"foil\": true, \"condition\": \"Mint\", \"acquiredAt\": \"2024-01-01T00:00:00Z\", \"acquiredVia\": \"Purchase\", \"player\": $ID_Player, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT friendships/$ID_Friendship ==="
curl -s -X PUT "$BASE/friendships/$ID_Friendship" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"requester\": $ID_Player, \"receiver\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT player_achievements/$ID_PlayerAchievement ==="
curl -s -X PUT "$BASE/player_achievements/$ID_PlayerAchievement" \
  -H "Content-Type: application/json" \
  -d "{\"earnedAt\": \"2024-01-01T00:00:00Z\", \"progress\": 1, \"isCompleted\": true, \"player\": $ID_Player, \"achievement\": $ID_Achievement}" | python3 -m json.tool

echo && echo "=== PUT tournaments/$ID_Tournament ==="
curl -s -X PUT "$BASE/tournaments/$ID_Tournament" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"foo_name\", \"description\": \"foo_description\", \"format\": \"Standard\", \"tournamentType\": \"Swiss\", \"status\": \"Draft\", \"maxPlayers\": 1, \"entryFee\": \"1.00\", \"prizePool\": \"1.00\", \"startTime\": \"2024-01-01T00:00:00Z\", \"endTime\": \"2024-01-01T00:00:00Z\", \"isOnline\": true, \"location\": \"foo_location\", \"rulesText\": \"foo_rules_text\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"season\": $ID_Season, \"organizer\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT matches/$ID_Match ==="
curl -s -X PUT "$BASE/matches/$ID_Match" \
  -H "Content-Type: application/json" \
  -d "{\"tableNumber\": 1, \"status\": \"Pending\", \"player1Wins\": 1, \"player2Wins\": 1, \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"resultNotes\": \"foo_result_notes\", \"player1\": $ID_Player, \"player2\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT orders/$ID_Order ==="
curl -s -X PUT "$BASE/orders/$ID_Order" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Pending\", \"total\": \"1.00\", \"discountApplied\": \"1.00\", \"currency\": \"foo\", \"paymentMethod\": \"Card\", \"paymentReference\": \"foo_payment_reference\", \"shippingAddress\": \"foo_shipping_address\", \"trackingNumber\": \"foo_tracking_number\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"paidAt\": \"2024-01-01T00:00:00Z\", \"shippedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player, \"items\": $ID_OrderItem, \"coupon\": ${ID_Coupon:-null}}" | python3 -m json.tool

echo && echo "=== PUT tradelistings/$ID_Tradelisting ==="
curl -s -X PUT "$BASE/tradelistings/$ID_Tradelisting" \
  -H "Content-Type: application/json" \
  -d "{\"listingType\": \"FixedPrice\", \"askingPrice\": \"1.00\", \"auctionStartPrice\": \"1.00\", \"auctionCurrentBid\": \"1.00\", \"auctionEndTime\": \"2024-01-01T00:00:00Z\", \"foil\": true, \"condition\": \"Mint\", \"quantity\": 1, \"status\": \"Active\", \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"expiresAt\": \"2024-01-01T00:00:00Z\", \"seller\": $ID_Player, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT draft_participants/$ID_DraftParticipant ==="
curl -s -X PUT "$BASE/draft_participants/$ID_DraftParticipant" \
  -H "Content-Type: application/json" \
  -d "{\"seatNumber\": 1, \"joinedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT article_comments/$ID_ArticleComment ==="
curl -s -X PUT "$BASE/article_comments/$ID_ArticleComment" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"isHidden\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"author\": $ID_Player, \"parentComment\": ${ID_ArticleComment:-null}}" | python3 -m json.tool

echo && echo "=== PUT streams/$ID_Stream ==="
curl -s -X PUT "$BASE/streams/$ID_Stream" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"streamUrl\": \"https://example.com/foo\", \"platform\": \"Twitch\", \"status\": \"Scheduled\", \"viewerCountPeak\": 1, \"scheduledStart\": \"2024-01-01T00:00:00Z\", \"actualStart\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"vodUrl\": \"https://example.com/foo\", \"tournament\": ${ID_Tournament:-null}, \"streamer\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT content_likes/$ID_ContentLike ==="
curl -s -X PUT "$BASE/content_likes/$ID_ContentLike" \
  -H "Content-Type: application/json" \
  -d "{\"targetType\": \"Article\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player, \"article\": ${ID_Article:-null}, \"deck\": ${ID_Deck:-null}}" | python3 -m json.tool

echo && echo "=== PUT bookmarks/$ID_Bookmark ==="
curl -s -X PUT "$BASE/bookmarks/$ID_Bookmark" \
  -H "Content-Type: application/json" \
  -d "{\"targetType\": \"Article\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player, \"article\": ${ID_Article:-null}, \"deck\": ${ID_Deck:-null}}" | python3 -m json.tool

echo && echo "=== PUT notifications/$ID_Notification ==="
curl -s -X PUT "$BASE/notifications/$ID_Notification" \
  -H "Content-Type: application/json" \
  -d "{\"notificationType\": \"TournamentStart\", \"title\": \"foo_title\", \"body\": \"foo_body\", \"isRead\": true, \"readAt\": \"2024-01-01T00:00:00Z\", \"actionUrl\": \"foo_action_url\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT notification_preferences/$ID_NotificationPreference ==="
curl -s -X PUT "$BASE/notification_preferences/$ID_NotificationPreference" \
  -H "Content-Type: application/json" \
  -d "{\"notificationType\": \"TournamentStart\", \"emailEnabled\": true, \"pushEnabled\": true, \"inAppEnabled\": true, \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT push_devices/$ID_PushDevice ==="
curl -s -X PUT "$BASE/push_devices/$ID_PushDevice" \
  -H "Content-Type: application/json" \
  -d "{\"deviceToken\": \"foo_device_token\", \"platform\": \"iOS\", \"deviceName\": \"foo_device_name\", \"isActive\": true, \"registeredAt\": \"2024-01-01T00:00:00Z\", \"lastUsedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT messages/$ID_Message ==="
curl -s -X PUT "$BASE/messages/$ID_Message" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"foo_body\", \"isRead\": true, \"readAt\": \"2024-01-01T00:00:00Z\", \"isDeletedBySender\": true, \"isDeletedByReceiver\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"sender\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT player_reports/$ID_PlayerReport ==="
curl -s -X PUT "$BASE/player_reports/$ID_PlayerReport" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"Cheating\", \"description\": \"foo_description\", \"status\": \"Open\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"reviewedAt\": \"2024-01-01T00:00:00Z\", \"reportedPlayer\": $ID_Player, \"reporter\": $ID_Player, \"reviewedBy\": ${ID_Player:-null}, \"match\": ${ID_Match:-null}}" | python3 -m json.tool

echo && echo "=== PUT moderation_actions/$ID_ModerationAction ==="
curl -s -X PUT "$BASE/moderation_actions/$ID_ModerationAction" \
  -H "Content-Type: application/json" \
  -d "{\"actionType\": \"Warning\", \"reason\": \"foo_reason\", \"durationDays\": 1, \"expiresAt\": \"2024-01-01T00:00:00Z\", \"isActive\": true, \"createdAt\": \"2024-01-01T00:00:00Z\", \"revokedAt\": \"2024-01-01T00:00:00Z\", \"revokeReason\": \"foo_revoke_reason\", \"player\": $ID_Player, \"moderator\": $ID_Player, \"report\": ${ID_PlayerReport:-null}}" | python3 -m json.tool

echo && echo "=== PUT content_reports/$ID_ContentReport ==="
curl -s -X PUT "$BASE/content_reports/$ID_ContentReport" \
  -H "Content-Type: application/json" \
  -d "{\"targetType\": \"Article\", \"reason\": \"Spam\", \"description\": \"foo_description\", \"status\": \"Open\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"reviewedAt\": \"2024-01-01T00:00:00Z\", \"reporter\": $ID_Player, \"reviewedBy\": ${ID_Player:-null}, \"article\": ${ID_Article:-null}, \"articleComment\": ${ID_ArticleComment:-null}}" | python3 -m json.tool

echo && echo "=== PUT wallets/$ID_Wallet ==="
curl -s -X PUT "$BASE/wallets/$ID_Wallet" \
  -H "Content-Type: application/json" \
  -d "{\"creditsBalance\": \"1.00\", \"dustBalance\": 1, \"gemsBalance\": 1, \"updatedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT top_up_orders/$ID_TopUpOrder ==="
curl -s -X PUT "$BASE/top_up_orders/$ID_TopUpOrder" \
  -H "Content-Type: application/json" \
  -d "{\"amountPaid\": \"1.00\", \"currencyPaid\": \"foo\", \"creditsGranted\": \"1.00\", \"gemsGranted\": 1, \"paymentMethod\": \"Card\", \"paymentReference\": \"foo_payment_reference\", \"status\": \"Pending\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT leaderboard_entries/$ID_LeaderboardEntry ==="
curl -s -X PUT "$BASE/leaderboard_entries/$ID_LeaderboardEntry" \
  -H "Content-Type: application/json" \
  -d "{\"position\": 1, \"rating\": 1, \"wins\": 1, \"losses\": 1, \"winRate\": \"1.00\", \"tournamentWins\": 1, \"seasonPoints\": 1, \"updatedAt\": \"2024-01-01T00:00:00Z\", \"player\": $ID_Player, \"season\": $ID_Season}" | python3 -m json.tool

echo && echo "=== PUT audit_logs/$ID_AuditLog ==="
curl -s -X PUT "$BASE/audit_logs/$ID_AuditLog" \
  -H "Content-Type: application/json" \
  -d "{\"action\": \"foo_action\", \"targetType\": \"foo_target_type\", \"targetId\": \"foo_target_id\", \"oldValue\": \"foo_old_value\", \"newValue\": \"foo_new_value\", \"ipAddress\": \"foo_ip_address\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"admin\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT platform_configs/$ID_PlatformConfig ==="
curl -s -X PUT "$BASE/platform_configs/$ID_PlatformConfig" \
  -H "Content-Type: application/json" \
  -d "{\"configKey\": \"foo_config_key\", \"configValue\": \"foo_config_value\", \"valueType\": \"Int\", \"description\": \"foo_description\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"updatedBy\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT deck_cards/$ID_DeckCard ==="
curl -s -X PUT "$BASE/deck_cards/$ID_DeckCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"isCommander\": true, \"deck\": $ID_Deck, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X PUT "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" \
  -H "Content-Type: application/json" \
  -d "{\"quantity\": 1, \"deck\": $ID_Deck, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s -X PUT "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" \
  -H "Content-Type: application/json" \
  -d "{\"deck\": $ID_Deck, \"tag\": $ID_DeckTag}" | python3 -m json.tool

echo && echo "=== PUT deck_reviews/$ID_DeckReview ==="
curl -s -X PUT "$BASE/deck_reviews/$ID_DeckReview" \
  -H "Content-Type: application/json" \
  -d "{\"rating\": 1, \"body\": \"foo_body\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"deck\": $ID_Deck, \"author\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT tournament_judges/$ID_TournamentJudge ==="
curl -s -X PUT "$BASE/tournament_judges/$ID_TournamentJudge" \
  -H "Content-Type: application/json" \
  -d "{\"role\": \"HeadJudge\", \"tournament\": $ID_Tournament, \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT tournament_registrations/$ID_TournamentRegistration ==="
curl -s -X PUT "$BASE/tournament_registrations/$ID_TournamentRegistration" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"Registered\", \"seed\": 1, \"finalStanding\": 1, \"pointsEarned\": 1, \"registeredAt\": \"2024-01-01T00:00:00Z\", \"tournament\": $ID_Tournament, \"player\": $ID_Player, \"deck\": $ID_Deck}" | python3 -m json.tool

echo && echo "=== PUT tournament_prizes/$ID_TournamentPrize ==="
curl -s -X PUT "$BASE/tournament_prizes/$ID_TournamentPrize" \
  -H "Content-Type: application/json" \
  -d "{\"placementFrom\": 1, \"placementTo\": 1, \"prizeType\": \"Currency\", \"amount\": \"1.00\", \"description\": \"foo_description\", \"packsCount\": 1, \"seasonPoints\": 1, \"tournament\": $ID_Tournament}" | python3 -m json.tool

echo && echo "=== PUT tournament_rounds/$ID_TournamentRound ==="
curl -s -X PUT "$BASE/tournament_rounds/$ID_TournamentRound" \
  -H "Content-Type: application/json" \
  -d "{\"roundNumber\": 1, \"status\": \"Pending\", \"startedAt\": \"2024-01-01T00:00:00Z\", \"endedAt\": \"2024-01-01T00:00:00Z\", \"timeLimitMinutes\": 1, \"tournament\": $ID_Tournament, \"matches\": $ID_Match}" | python3 -m json.tool

echo && echo "=== PUT games/$ID_Game ==="
curl -s -X PUT "$BASE/games/$ID_Game" \
  -H "Content-Type: application/json" \
  -d "{\"gameNumber\": 1, \"winnerSide\": \"Player1\", \"turnsPlayed\": 1, \"durationSeconds\": 1, \"endedBy\": \"Normal\", \"replayUrl\": \"https://example.com/foo\", \"match\": $ID_Match, \"winner\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT trade_bids/$ID_TradeBid ==="
curl -s -X PUT "$BASE/trade_bids/$ID_TradeBid" \
  -H "Content-Type: application/json" \
  -d "{\"amount\": \"1.00\", \"placedAt\": \"2024-01-01T00:00:00Z\", \"isWinning\": true, \"listing\": $ID_Tradelisting, \"bidder\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT trade_transactions/$ID_TradeTransaction ==="
curl -s -X PUT "$BASE/trade_transactions/$ID_TradeTransaction" \
  -H "Content-Type: application/json" \
  -d "{\"finalPrice\": \"1.00\", \"platformFee\": \"1.00\", \"status\": \"Pending\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"listing\": $ID_Tradelisting, \"buyer\": $ID_Player, \"seller\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT draft_sessions/$ID_DraftSession ==="
curl -s -X PUT "$BASE/draft_sessions/$ID_DraftSession" \
  -H "Content-Type: application/json" \
  -d "{\"status\": \"WaitingForPlayers\", \"draftType\": \"Booster\", \"seats\": 1, \"createdAt\": \"2024-01-01T00:00:00Z\", \"completedAt\": \"2024-01-01T00:00:00Z\", \"cardSet\": $ID_CardSet, \"participants\": $ID_DraftParticipant}" | python3 -m json.tool

echo && echo "=== PUT draft_picks/$ID_DraftPick ==="
curl -s -X PUT "$BASE/draft_picks/$ID_DraftPick" \
  -H "Content-Type: application/json" \
  -d "{\"pickNumber\": 1, \"packNumber\": 1, \"pickedAt\": \"2024-01-01T00:00:00Z\", \"participant\": $ID_DraftParticipant, \"card\": $ID_Card}" | python3 -m json.tool

echo && echo "=== PUT articles/$ID_Article ==="
curl -s -X PUT "$BASE/articles/$ID_Article" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"foo_title\", \"slug\": \"foo_slug\", \"body\": \"foo_body\", \"excerpt\": \"foo_excerpt\", \"coverImageUrl\": \"https://example.com/foo\", \"status\": \"Draft\", \"articleType\": \"Guide\", \"viewCount\": 1, \"publishedAt\": \"2024-01-01T00:00:00Z\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"updatedAt\": \"2024-01-01T00:00:00Z\", \"author\": $ID_Player, \"featuredDeck\": ${ID_Deck:-null}, \"comments\": $ID_ArticleComment}" | python3 -m json.tool

echo && echo "=== PUT conversations/$ID_Conversation ==="
curl -s -X PUT "$BASE/conversations/$ID_Conversation" \
  -H "Content-Type: application/json" \
  -d "{\"createdAt\": \"2024-01-01T00:00:00Z\", \"lastMessageAt\": \"2024-01-01T00:00:00Z\", \"isArchivedByPlayer1\": true, \"isArchivedByPlayer2\": true, \"player1\": $ID_Player, \"player2\": $ID_Player, \"messages\": $ID_Message}" | python3 -m json.tool

echo && echo "=== PUT wallet_transactions/$ID_WalletTransaction ==="
curl -s -X PUT "$BASE/wallet_transactions/$ID_WalletTransaction" \
  -H "Content-Type: application/json" \
  -d "{\"transactionType\": \"TopUp\", \"currency\": \"Credits\", \"amount\": \"1.00\", \"balanceAfter\": \"1.00\", \"description\": \"foo_description\", \"createdAt\": \"2024-01-01T00:00:00Z\", \"wallet\": $ID_Wallet, \"order\": ${ID_Order:-null}, \"tradeTransaction\": ${ID_TradeTransaction:-null}}" | python3 -m json.tool

echo && echo "=== PUT leaderboard_snapshots/$ID_LeaderboardSnapshot ==="
curl -s -X PUT "$BASE/leaderboard_snapshots/$ID_LeaderboardSnapshot" \
  -H "Content-Type: application/json" \
  -d "{\"snapshotDate\": \"2024-01-01\", \"position\": 1, \"rating\": 1, \"seasonPoints\": 1, \"entry\": $ID_LeaderboardEntry}" | python3 -m json.tool

echo && echo "=== PUT awarded_prizes/$ID_AwardedPrize ==="
curl -s -X PUT "$BASE/awarded_prizes/$ID_AwardedPrize" \
  -H "Content-Type: application/json" \
  -d "{\"finalPlacement\": 1, \"awardedAt\": \"2024-01-01T00:00:00Z\", \"claimed\": true, \"claimedAt\": \"2024-01-01T00:00:00Z\", \"prize\": $ID_TournamentPrize, \"player\": $ID_Player}" | python3 -m json.tool

echo && echo "=== PUT trade_disputes/$ID_TradeDispute ==="
curl -s -X PUT "$BASE/trade_disputes/$ID_TradeDispute" \
  -H "Content-Type: application/json" \
  -d "{\"reason\": \"ItemNotReceived\", \"description\": \"foo_description\", \"status\": \"Open\", \"resolution\": \"foo_resolution\", \"openedAt\": \"2024-01-01T00:00:00Z\", \"resolvedAt\": \"2024-01-01T00:00:00Z\", \"transaction\": $ID_TradeTransaction, \"openedBy\": $ID_Player, \"resolvedBy\": ${ID_Player:-null}}" | python3 -m json.tool

echo && echo "=== PUT article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s -X PUT "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" \
  -H "Content-Type: application/json" \
  -d "{\"article\": $ID_Article, \"tag\": $ID_ArticleTag}" | python3 -m json.tool
