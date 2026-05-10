#!/usr/bin/env bash
BASE="http://localhost:4000/api"

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

echo && echo "=== DELETE article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s -X DELETE "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE trade_disputes/$ID_TradeDispute ==="
curl -s -X DELETE "$BASE/trade_disputes/$ID_TradeDispute" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE awarded_prizes/$ID_AwardedPrize ==="
curl -s -X DELETE "$BASE/awarded_prizes/$ID_AwardedPrize" -o /dev/null -w "HTTP %{http_code}\n"

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

echo && echo "=== DELETE deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s -X DELETE "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X DELETE "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_cards/$ID_DeckCard ==="
curl -s -X DELETE "$BASE/deck_cards/$ID_DeckCard" -o /dev/null -w "HTTP %{http_code}\n"

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
