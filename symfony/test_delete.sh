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

echo && echo "=== DELETE article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s -X DELETE "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE trade_disputes/$ID_TradeDispute ==="
curl -s -X DELETE "$BASE/trade_disputes/$ID_TradeDispute" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE awarded_prizes/$ID_AwardedPrize ==="
curl -s -X DELETE "$BASE/awarded_prizes/$ID_AwardedPrize" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE leaderboard_snapshots/$ID_LeaderboardSnapshot ==="
curl -s -X DELETE "$BASE/leaderboard_snapshots/$ID_LeaderboardSnapshot" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE wallet_transactions/$ID_WalletTransaction ==="
curl -s -X DELETE "$BASE/wallet_transactions/$ID_WalletTransaction" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE conversations/$ID_Conversation ==="
curl -s -X DELETE "$BASE/conversations/$ID_Conversation" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE articles/$ID_Article ==="
curl -s -X DELETE "$BASE/articles/$ID_Article" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE draft_picks/$ID_DraftPick ==="
curl -s -X DELETE "$BASE/draft_picks/$ID_DraftPick" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE draft_sessions/$ID_DraftSession ==="
curl -s -X DELETE "$BASE/draft_sessions/$ID_DraftSession" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE trade_transactions/$ID_TradeTransaction ==="
curl -s -X DELETE "$BASE/trade_transactions/$ID_TradeTransaction" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE trade_bids/$ID_TradeBid ==="
curl -s -X DELETE "$BASE/trade_bids/$ID_TradeBid" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE games/$ID_Game ==="
curl -s -X DELETE "$BASE/games/$ID_Game" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament_rounds/$ID_TournamentRound ==="
curl -s -X DELETE "$BASE/tournament_rounds/$ID_TournamentRound" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament_prizes/$ID_TournamentPrize ==="
curl -s -X DELETE "$BASE/tournament_prizes/$ID_TournamentPrize" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament_registrations/$ID_TournamentRegistration ==="
curl -s -X DELETE "$BASE/tournament_registrations/$ID_TournamentRegistration" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament_judges/$ID_TournamentJudge ==="
curl -s -X DELETE "$BASE/tournament_judges/$ID_TournamentJudge" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_reviews/$ID_DeckReview ==="
curl -s -X DELETE "$BASE/deck_reviews/$ID_DeckReview" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s -X DELETE "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X DELETE "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_cards/$ID_DeckCard ==="
curl -s -X DELETE "$BASE/deck_cards/$ID_DeckCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE platform_configs/$ID_PlatformConfig ==="
curl -s -X DELETE "$BASE/platform_configs/$ID_PlatformConfig" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE audit_logs/$ID_AuditLog ==="
curl -s -X DELETE "$BASE/audit_logs/$ID_AuditLog" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE leaderboard_entries/$ID_LeaderboardEntry ==="
curl -s -X DELETE "$BASE/leaderboard_entries/$ID_LeaderboardEntry" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE top_up_orders/$ID_TopUpOrder ==="
curl -s -X DELETE "$BASE/top_up_orders/$ID_TopUpOrder" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE wallets/$ID_Wallet ==="
curl -s -X DELETE "$BASE/wallets/$ID_Wallet" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE content_reports/$ID_ContentReport ==="
curl -s -X DELETE "$BASE/content_reports/$ID_ContentReport" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE moderation_actions/$ID_ModerationAction ==="
curl -s -X DELETE "$BASE/moderation_actions/$ID_ModerationAction" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE player_reports/$ID_PlayerReport ==="
curl -s -X DELETE "$BASE/player_reports/$ID_PlayerReport" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE messages/$ID_Message ==="
curl -s -X DELETE "$BASE/messages/$ID_Message" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE push_devices/$ID_PushDevice ==="
curl -s -X DELETE "$BASE/push_devices/$ID_PushDevice" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE notification_preferences/$ID_NotificationPreference ==="
curl -s -X DELETE "$BASE/notification_preferences/$ID_NotificationPreference" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE notifications/$ID_Notification ==="
curl -s -X DELETE "$BASE/notifications/$ID_Notification" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE bookmarks/$ID_Bookmark ==="
curl -s -X DELETE "$BASE/bookmarks/$ID_Bookmark" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE content_likes/$ID_ContentLike ==="
curl -s -X DELETE "$BASE/content_likes/$ID_ContentLike" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE streams/$ID_Stream ==="
curl -s -X DELETE "$BASE/streams/$ID_Stream" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article_comments/$ID_ArticleComment ==="
curl -s -X DELETE "$BASE/article_comments/$ID_ArticleComment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE draft_participants/$ID_DraftParticipant ==="
curl -s -X DELETE "$BASE/draft_participants/$ID_DraftParticipant" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tradelistings/$ID_Tradelisting ==="
curl -s -X DELETE "$BASE/tradelistings/$ID_Tradelisting" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE orders/$ID_Order ==="
curl -s -X DELETE "$BASE/orders/$ID_Order" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE matches/$ID_Match ==="
curl -s -X DELETE "$BASE/matches/$ID_Match" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournaments/$ID_Tournament ==="
curl -s -X DELETE "$BASE/tournaments/$ID_Tournament" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE player_achievements/$ID_PlayerAchievement ==="
curl -s -X DELETE "$BASE/player_achievements/$ID_PlayerAchievement" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE friendships/$ID_Friendship ==="
curl -s -X DELETE "$BASE/friendships/$ID_Friendship" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE player_collections/$ID_PlayerCollection ==="
curl -s -X DELETE "$BASE/player_collections/$ID_PlayerCollection" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE decks/$ID_Deck ==="
curl -s -X DELETE "$BASE/decks/$ID_Deck" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE crafting_ingredients/$ID_CraftingIngredient ==="
curl -s -X DELETE "$BASE/crafting_ingredients/$ID_CraftingIngredient" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE players/$ID_Player ==="
curl -s -X DELETE "$BASE/players/$ID_Player" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card_price_histories/$ID_CardPriceHistory ==="
curl -s -X DELETE "$BASE/card_price_histories/$ID_CardPriceHistory" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE crafting_recipes/$ID_CraftingRecipe ==="
curl -s -X DELETE "$BASE/crafting_recipes/$ID_CraftingRecipe" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card_abilities/$ID_CardAbility ==="
curl -s -X DELETE "$BASE/card_abilities/$ID_CardAbility" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card_rulings/$ID_CardRuling ==="
curl -s -X DELETE "$BASE/card_rulings/$ID_CardRuling" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE order_items/$ID_OrderItem ==="
curl -s -X DELETE "$BASE/order_items/$ID_OrderItem" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE player_season_statses/$ID_PlayerSeasonStats ==="
curl -s -X DELETE "$BASE/player_season_statses/$ID_PlayerSeasonStats" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE cards/$ID_Card ==="
curl -s -X DELETE "$BASE/cards/$ID_Card" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE system_announcements/$ID_SystemAnnouncement ==="
curl -s -X DELETE "$BASE/system_announcements/$ID_SystemAnnouncement" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE feature_flags/$ID_FeatureFlag ==="
curl -s -X DELETE "$BASE/feature_flags/$ID_FeatureFlag" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE top_up_packages/$ID_TopUpPackage ==="
curl -s -X DELETE "$BASE/top_up_packages/$ID_TopUpPackage" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article_tags/$ID_ArticleTag ==="
curl -s -X DELETE "$BASE/article_tags/$ID_ArticleTag" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE coupons/$ID_Coupon ==="
curl -s -X DELETE "$BASE/coupons/$ID_Coupon" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE products/$ID_Product ==="
curl -s -X DELETE "$BASE/products/$ID_Product" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE seasons/$ID_Season ==="
curl -s -X DELETE "$BASE/seasons/$ID_Season" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE achievements/$ID_Achievement ==="
curl -s -X DELETE "$BASE/achievements/$ID_Achievement" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_tags/$ID_DeckTag ==="
curl -s -X DELETE "$BASE/deck_tags/$ID_DeckTag" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card_sets/$ID_CardSet ==="
curl -s -X DELETE "$BASE/card_sets/$ID_CardSet" -o /dev/null -w "HTTP %{http_code}\n"
