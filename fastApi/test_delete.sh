#!/usr/bin/env bash
BASE="http://localhost:8000/api"

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

echo && echo "=== DELETE crafting_ingredients/$ID_CraftingIngredient ==="
curl -s -X DELETE "$BASE/crafting_ingredients/$ID_CraftingIngredient" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament_prizes/$ID_TournamentPrize ==="
curl -s -X DELETE "$BASE/tournament_prizes/$ID_TournamentPrize" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament_judges/$ID_TournamentJudge ==="
curl -s -X DELETE "$BASE/tournament_judges/$ID_TournamentJudge" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article_comments/$ID_ArticleComment ==="
curl -s -X DELETE "$BASE/article_comments/$ID_ArticleComment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s -X DELETE "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE order_items/$ID_OrderItem ==="
curl -s -X DELETE "$BASE/order_items/$ID_OrderItem" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s -X DELETE "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s -X DELETE "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_cards/$ID_DeckCard ==="
curl -s -X DELETE "$BASE/deck_cards/$ID_DeckCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE player_collections/$ID_PlayerCollection ==="
curl -s -X DELETE "$BASE/player_collections/$ID_PlayerCollection" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card_abilities/$ID_CardAbility ==="
curl -s -X DELETE "$BASE/card_abilities/$ID_CardAbility" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card_rulings/$ID_CardRuling ==="
curl -s -X DELETE "$BASE/card_rulings/$ID_CardRuling" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE friendships/$ID_Friendship ==="
curl -s -X DELETE "$BASE/friendships/$ID_Friendship" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE decks/$ID_Deck ==="
curl -s -X DELETE "$BASE/decks/$ID_Deck" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article_tags/$ID_ArticleTag ==="
curl -s -X DELETE "$BASE/article_tags/$ID_ArticleTag" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck_tags/$ID_DeckTag ==="
curl -s -X DELETE "$BASE/deck_tags/$ID_DeckTag" -o /dev/null -w "HTTP %{http_code}\n"
