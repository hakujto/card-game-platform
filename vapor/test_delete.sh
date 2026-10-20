#!/usr/bin/env bash
BASE="http://localhost:8080/api"

ID_CardSet=00000000-0000-0000-0000-000000000000
ID_DeckTag=00000000-0000-0000-0000-000000000000
ID_Player=00000000-0000-0000-0000-000000000000
ID_Achievement=00000000-0000-0000-0000-000000000000
ID_Season=00000000-0000-0000-0000-000000000000
ID_Product=00000000-0000-0000-0000-000000000000
ID_Coupon=00000000-0000-0000-0000-000000000000
ID_ArticleTag=00000000-0000-0000-0000-000000000000
ID_Card=00000000-0000-0000-0000-000000000000
ID_DraftSession=00000000-0000-0000-0000-000000000000
ID_Deck=00000000-0000-0000-0000-000000000000
ID_Friendship=00000000-0000-0000-0000-000000000000
ID_Order=00000000-0000-0000-0000-000000000000
ID_Article=00000000-0000-0000-0000-000000000000
ID_Stream=00000000-0000-0000-0000-000000000000
ID_PlayerAchievement=00000000-0000-0000-0000-000000000000
ID_PlayerSeasonStats=00000000-0000-0000-0000-000000000000
ID_Tournament=00000000-0000-0000-0000-000000000000
ID_CardRuling=00000000-0000-0000-0000-000000000000
ID_CardAbility=00000000-0000-0000-0000-000000000000
ID_PlayerCollection=00000000-0000-0000-0000-000000000000
ID_CraftingRecipe=00000000-0000-0000-0000-000000000000
ID_TradeListing=00000000-0000-0000-0000-000000000000
ID_CardPriceHistory=00000000-0000-0000-0000-000000000000
ID_DraftParticipant=00000000-0000-0000-0000-000000000000
ID_DeckCard=00000000-0000-0000-0000-000000000000
ID_DeckSideboardCard=00000000-0000-0000-0000-000000000000
ID_DeckTagAssignment=00000000-0000-0000-0000-000000000000
ID_OrderItem=00000000-0000-0000-0000-000000000000
ID_ArticleTagAssignment=00000000-0000-0000-0000-000000000000
ID_ArticleComment=00000000-0000-0000-0000-000000000000
ID_TournamentJudge=00000000-0000-0000-0000-000000000000
ID_TournamentRegistration=00000000-0000-0000-0000-000000000000
ID_TournamentRound=00000000-0000-0000-0000-000000000000
ID_TournamentPrize=00000000-0000-0000-0000-000000000000
ID_CraftingIngredient=00000000-0000-0000-0000-000000000000
ID_TradeBid=00000000-0000-0000-0000-000000000000
ID_TradeTransaction=00000000-0000-0000-0000-000000000000
ID_DraftPick=00000000-0000-0000-0000-000000000000
ID_Match=00000000-0000-0000-0000-000000000000
ID_AwardedPrize=00000000-0000-0000-0000-000000000000
ID_TradeDispute=00000000-0000-0000-0000-000000000000
ID_Game=00000000-0000-0000-0000-000000000000

echo && echo "=== DELETE crafting-ingredients/$ID_CraftingIngredient ==="
curl -s -X DELETE "$BASE/crafting-ingredients/$ID_CraftingIngredient" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament-prizes/$ID_TournamentPrize ==="
curl -s -X DELETE "$BASE/tournament-prizes/$ID_TournamentPrize" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE tournament-judges/$ID_TournamentJudge ==="
curl -s -X DELETE "$BASE/tournament-judges/$ID_TournamentJudge" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article-comments/$ID_ArticleComment ==="
curl -s -X DELETE "$BASE/article-comments/$ID_ArticleComment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article-tag-assignments/$ID_ArticleTagAssignment ==="
curl -s -X DELETE "$BASE/article-tag-assignments/$ID_ArticleTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE order-items/$ID_OrderItem ==="
curl -s -X DELETE "$BASE/order-items/$ID_OrderItem" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck-tag-assignments/$ID_DeckTagAssignment ==="
curl -s -X DELETE "$BASE/deck-tag-assignments/$ID_DeckTagAssignment" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck-sideboard-cards/$ID_DeckSideboardCard ==="
curl -s -X DELETE "$BASE/deck-sideboard-cards/$ID_DeckSideboardCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck-cards/$ID_DeckCard ==="
curl -s -X DELETE "$BASE/deck-cards/$ID_DeckCard" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE player-collections/$ID_PlayerCollection ==="
curl -s -X DELETE -H "X-User-Id: 1" "$BASE/player-collections/$ID_PlayerCollection" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card-abilities/$ID_CardAbility ==="
curl -s -X DELETE "$BASE/card-abilities/$ID_CardAbility" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE card-rulings/$ID_CardRuling ==="
curl -s -X DELETE "$BASE/card-rulings/$ID_CardRuling" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE friendships/$ID_Friendship ==="
curl -s -X DELETE -H "X-User-Id: 1" "$BASE/friendships/$ID_Friendship" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE decks/$ID_Deck ==="
curl -s -X DELETE "$BASE/decks/$ID_Deck" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE article-tags/$ID_ArticleTag ==="
curl -s -X DELETE "$BASE/article-tags/$ID_ArticleTag" -o /dev/null -w "HTTP %{http_code}\n"

echo && echo "=== DELETE deck-tags/$ID_DeckTag ==="
curl -s -X DELETE "$BASE/deck-tags/$ID_DeckTag" -o /dev/null -w "HTTP %{http_code}\n"
