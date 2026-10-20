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

echo && echo "=== GET card-sets ==="
curl -s "$BASE/card-sets" | python3 -m json.tool
echo && echo "=== GET card-sets/$ID_CardSet ==="
curl -s "$BASE/card-sets/$ID_CardSet" | python3 -m json.tool

echo && echo "=== GET deck-tags ==="
curl -s "$BASE/deck-tags" | python3 -m json.tool
echo && echo "=== GET deck-tags/$ID_DeckTag ==="
curl -s "$BASE/deck-tags/$ID_DeckTag" | python3 -m json.tool

echo && echo "=== GET players ==="
curl -s "$BASE/players" | python3 -m json.tool
echo && echo "=== GET players/$ID_Player ==="
curl -s "$BASE/players/$ID_Player" | python3 -m json.tool

echo && echo "=== GET achievements ==="
curl -s "$BASE/achievements" | python3 -m json.tool
echo && echo "=== GET achievements/$ID_Achievement ==="
curl -s "$BASE/achievements/$ID_Achievement" | python3 -m json.tool

echo && echo "=== GET seasons ==="
curl -s "$BASE/seasons" | python3 -m json.tool
echo && echo "=== GET seasons/$ID_Season ==="
curl -s "$BASE/seasons/$ID_Season" | python3 -m json.tool

echo && echo "=== GET products ==="
curl -s "$BASE/products" | python3 -m json.tool
echo && echo "=== GET products/$ID_Product ==="
curl -s "$BASE/products/$ID_Product" | python3 -m json.tool

echo && echo "=== GET coupons ==="
curl -s "$BASE/coupons" | python3 -m json.tool
echo && echo "=== GET coupons/$ID_Coupon ==="
curl -s "$BASE/coupons/$ID_Coupon" | python3 -m json.tool

echo && echo "=== GET article-tags ==="
curl -s "$BASE/article-tags" | python3 -m json.tool
echo && echo "=== GET article-tags/$ID_ArticleTag ==="
curl -s "$BASE/article-tags/$ID_ArticleTag" | python3 -m json.tool

echo && echo "=== GET cards ==="
curl -s "$BASE/cards" | python3 -m json.tool
echo && echo "=== GET cards/$ID_Card ==="
curl -s "$BASE/cards/$ID_Card" | python3 -m json.tool

echo && echo "=== GET draft-sessions ==="
curl -s "$BASE/draft-sessions" | python3 -m json.tool
echo && echo "=== GET draft-sessions/$ID_DraftSession ==="
curl -s "$BASE/draft-sessions/$ID_DraftSession" | python3 -m json.tool

echo && echo "=== GET decks ==="
curl -s "$BASE/decks" | python3 -m json.tool
echo && echo "=== GET decks/$ID_Deck ==="
curl -s "$BASE/decks/$ID_Deck" | python3 -m json.tool

echo && echo "=== GET friendships ==="
curl -s "$BASE/friendships" | python3 -m json.tool
echo && echo "=== GET friendships/$ID_Friendship ==="
curl -s -H "X-User-Id: 1" "$BASE/friendships/$ID_Friendship" | python3 -m json.tool

echo && echo "=== GET orders ==="
curl -s "$BASE/orders" | python3 -m json.tool
echo && echo "=== GET orders/$ID_Order ==="
curl -s -H "X-User-Id: 1" "$BASE/orders/$ID_Order" | python3 -m json.tool

echo && echo "=== GET articles ==="
curl -s "$BASE/articles" | python3 -m json.tool
echo && echo "=== GET articles/$ID_Article ==="
curl -s "$BASE/articles/$ID_Article" | python3 -m json.tool

echo && echo "=== GET streams ==="
curl -s "$BASE/streams" | python3 -m json.tool
echo && echo "=== GET streams/$ID_Stream ==="
curl -s "$BASE/streams/$ID_Stream" | python3 -m json.tool

echo && echo "=== GET player-achievements ==="
curl -s "$BASE/player-achievements" | python3 -m json.tool

echo && echo "=== GET player-season-statses ==="
curl -s "$BASE/player-season-statses" | python3 -m json.tool

echo && echo "=== GET tournaments ==="
curl -s "$BASE/tournaments" | python3 -m json.tool
echo && echo "=== GET tournaments/$ID_Tournament ==="
curl -s "$BASE/tournaments/$ID_Tournament" | python3 -m json.tool

echo && echo "=== GET card-rulings ==="
curl -s "$BASE/card-rulings" | python3 -m json.tool
echo && echo "=== GET card-rulings/$ID_CardRuling ==="
curl -s "$BASE/card-rulings/$ID_CardRuling" | python3 -m json.tool

echo && echo "=== GET card-abilities ==="
curl -s "$BASE/card-abilities" | python3 -m json.tool
echo && echo "=== GET card-abilities/$ID_CardAbility ==="
curl -s "$BASE/card-abilities/$ID_CardAbility" | python3 -m json.tool

echo && echo "=== GET player-collections ==="
curl -s "$BASE/player-collections" | python3 -m json.tool
echo && echo "=== GET player-collections/$ID_PlayerCollection ==="
curl -s -H "X-User-Id: 1" "$BASE/player-collections/$ID_PlayerCollection" | python3 -m json.tool

echo && echo "=== GET crafting-recipes ==="
curl -s "$BASE/crafting-recipes" | python3 -m json.tool
echo && echo "=== GET crafting-recipes/$ID_CraftingRecipe ==="
curl -s "$BASE/crafting-recipes/$ID_CraftingRecipe" | python3 -m json.tool

echo && echo "=== GET trade-listings ==="
curl -s "$BASE/trade-listings" | python3 -m json.tool
echo && echo "=== GET trade-listings/$ID_TradeListing ==="
curl -s "$BASE/trade-listings/$ID_TradeListing" | python3 -m json.tool

echo && echo "=== GET card-price-histories ==="
curl -s "$BASE/card-price-histories" | python3 -m json.tool

echo && echo "=== GET draft-participants ==="
curl -s "$BASE/draft-participants" | python3 -m json.tool
echo && echo "=== GET draft-participants/$ID_DraftParticipant ==="
curl -s "$BASE/draft-participants/$ID_DraftParticipant" | python3 -m json.tool

echo && echo "=== GET deck-cards ==="
curl -s "$BASE/deck-cards" | python3 -m json.tool
echo && echo "=== GET deck-cards/$ID_DeckCard ==="
curl -s "$BASE/deck-cards/$ID_DeckCard" | python3 -m json.tool

echo && echo "=== GET deck-sideboard-cards ==="
curl -s "$BASE/deck-sideboard-cards" | python3 -m json.tool
echo && echo "=== GET deck-sideboard-cards/$ID_DeckSideboardCard ==="
curl -s "$BASE/deck-sideboard-cards/$ID_DeckSideboardCard" | python3 -m json.tool

echo && echo "=== GET deck-tag-assignments ==="
curl -s "$BASE/deck-tag-assignments" | python3 -m json.tool
echo && echo "=== GET deck-tag-assignments/$ID_DeckTagAssignment ==="
curl -s "$BASE/deck-tag-assignments/$ID_DeckTagAssignment" | python3 -m json.tool

echo && echo "=== GET order-items ==="
curl -s "$BASE/order-items" | python3 -m json.tool
echo && echo "=== GET order-items/$ID_OrderItem ==="
curl -s "$BASE/order-items/$ID_OrderItem" | python3 -m json.tool

echo && echo "=== GET article-tag-assignments ==="
curl -s "$BASE/article-tag-assignments" | python3 -m json.tool
echo && echo "=== GET article-tag-assignments/$ID_ArticleTagAssignment ==="
curl -s "$BASE/article-tag-assignments/$ID_ArticleTagAssignment" | python3 -m json.tool

echo && echo "=== GET article-comments ==="
curl -s "$BASE/article-comments" | python3 -m json.tool
echo && echo "=== GET article-comments/$ID_ArticleComment ==="
curl -s "$BASE/article-comments/$ID_ArticleComment" | python3 -m json.tool

echo && echo "=== GET tournament-judges ==="
curl -s "$BASE/tournament-judges" | python3 -m json.tool
echo && echo "=== GET tournament-judges/$ID_TournamentJudge ==="
curl -s "$BASE/tournament-judges/$ID_TournamentJudge" | python3 -m json.tool

echo && echo "=== GET tournament-registrations ==="
curl -s "$BASE/tournament-registrations" | python3 -m json.tool
echo && echo "=== GET tournament-registrations/$ID_TournamentRegistration ==="
curl -s -H "X-User-Id: 1" "$BASE/tournament-registrations/$ID_TournamentRegistration" | python3 -m json.tool

echo && echo "=== GET tournament-rounds ==="
curl -s "$BASE/tournament-rounds" | python3 -m json.tool
echo && echo "=== GET tournament-rounds/$ID_TournamentRound ==="
curl -s "$BASE/tournament-rounds/$ID_TournamentRound" | python3 -m json.tool

echo && echo "=== GET tournament-prizes ==="
curl -s "$BASE/tournament-prizes" | python3 -m json.tool
echo && echo "=== GET tournament-prizes/$ID_TournamentPrize ==="
curl -s "$BASE/tournament-prizes/$ID_TournamentPrize" | python3 -m json.tool

echo && echo "=== GET crafting-ingredients ==="
curl -s "$BASE/crafting-ingredients" | python3 -m json.tool
echo && echo "=== GET crafting-ingredients/$ID_CraftingIngredient ==="
curl -s "$BASE/crafting-ingredients/$ID_CraftingIngredient" | python3 -m json.tool

echo && echo "=== GET trade-bids ==="
curl -s "$BASE/trade-bids" | python3 -m json.tool
echo && echo "=== GET trade-bids/$ID_TradeBid ==="
curl -s "$BASE/trade-bids/$ID_TradeBid" | python3 -m json.tool

echo && echo "=== GET trade-transactions ==="
curl -s "$BASE/trade-transactions" | python3 -m json.tool

echo && echo "=== GET draft-picks ==="
curl -s "$BASE/draft-picks" | python3 -m json.tool

echo && echo "=== GET matches ==="
curl -s "$BASE/matches" | python3 -m json.tool
echo && echo "=== GET matches/$ID_Match ==="
curl -s "$BASE/matches/$ID_Match" | python3 -m json.tool

echo && echo "=== GET awarded-prizes ==="
curl -s "$BASE/awarded-prizes" | python3 -m json.tool

echo && echo "=== GET trade-disputes ==="
curl -s "$BASE/trade-disputes" | python3 -m json.tool

echo && echo "=== GET games ==="
curl -s "$BASE/games" | python3 -m json.tool
echo && echo "=== GET games/$ID_Game ==="
curl -s "$BASE/games/$ID_Game" | python3 -m json.tool
