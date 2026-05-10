#!/usr/bin/env bash
BASE="http://localhost:8080/api"

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

echo && echo "=== GET card_sets ==="
curl -s "$BASE/card_sets" | python3 -m json.tool
echo && echo "=== GET card_sets/$ID_CardSet ==="
curl -s "$BASE/card_sets/$ID_CardSet" | python3 -m json.tool

echo && echo "=== GET deck_tags ==="
curl -s "$BASE/deck_tags" | python3 -m json.tool
echo && echo "=== GET deck_tags/$ID_DeckTag ==="
curl -s "$BASE/deck_tags/$ID_DeckTag" | python3 -m json.tool

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

echo && echo "=== GET article_tags ==="
curl -s "$BASE/article_tags" | python3 -m json.tool
echo && echo "=== GET article_tags/$ID_ArticleTag ==="
curl -s "$BASE/article_tags/$ID_ArticleTag" | python3 -m json.tool

echo && echo "=== GET cards ==="
curl -s "$BASE/cards" | python3 -m json.tool
echo && echo "=== GET cards/$ID_Card ==="
curl -s "$BASE/cards/$ID_Card" | python3 -m json.tool

echo && echo "=== GET player_season_statses ==="
curl -s "$BASE/player_season_statses" | python3 -m json.tool
echo && echo "=== GET player_season_statses/$ID_PlayerSeasonStats ==="
curl -s "$BASE/player_season_statses/$ID_PlayerSeasonStats" | python3 -m json.tool

echo && echo "=== GET order_items ==="
curl -s "$BASE/order_items" | python3 -m json.tool
echo && echo "=== GET order_items/$ID_OrderItem ==="
curl -s "$BASE/order_items/$ID_OrderItem" | python3 -m json.tool

echo && echo "=== GET card_rulings ==="
curl -s "$BASE/card_rulings" | python3 -m json.tool
echo && echo "=== GET card_rulings/$ID_CardRuling ==="
curl -s "$BASE/card_rulings/$ID_CardRuling" | python3 -m json.tool

echo && echo "=== GET card_abilities ==="
curl -s "$BASE/card_abilities" | python3 -m json.tool
echo && echo "=== GET card_abilities/$ID_CardAbility ==="
curl -s "$BASE/card_abilities/$ID_CardAbility" | python3 -m json.tool

echo && echo "=== GET crafting_recipes ==="
curl -s "$BASE/crafting_recipes" | python3 -m json.tool
echo && echo "=== GET crafting_recipes/$ID_CraftingRecipe ==="
curl -s "$BASE/crafting_recipes/$ID_CraftingRecipe" | python3 -m json.tool

echo && echo "=== GET card_price_histories ==="
curl -s "$BASE/card_price_histories" | python3 -m json.tool
echo && echo "=== GET card_price_histories/$ID_CardPriceHistory ==="
curl -s "$BASE/card_price_histories/$ID_CardPriceHistory" | python3 -m json.tool

echo && echo "=== GET players ==="
curl -s "$BASE/players" | python3 -m json.tool
echo && echo "=== GET players/$ID_Player ==="
curl -s "$BASE/players/$ID_Player" | python3 -m json.tool

echo && echo "=== GET crafting_ingredients ==="
curl -s "$BASE/crafting_ingredients" | python3 -m json.tool
echo && echo "=== GET crafting_ingredients/$ID_CraftingIngredient ==="
curl -s "$BASE/crafting_ingredients/$ID_CraftingIngredient" | python3 -m json.tool

echo && echo "=== GET decks ==="
curl -s "$BASE/decks" | python3 -m json.tool
echo && echo "=== GET decks/$ID_Deck ==="
curl -s "$BASE/decks/$ID_Deck" | python3 -m json.tool

echo && echo "=== GET player_collections ==="
curl -s "$BASE/player_collections" | python3 -m json.tool
echo && echo "=== GET player_collections/$ID_PlayerCollection ==="
curl -s "$BASE/player_collections/$ID_PlayerCollection" | python3 -m json.tool

echo && echo "=== GET friendships ==="
curl -s "$BASE/friendships" | python3 -m json.tool
echo && echo "=== GET friendships/$ID_Friendship ==="
curl -s "$BASE/friendships/$ID_Friendship" | python3 -m json.tool

echo && echo "=== GET player_achievements ==="
curl -s "$BASE/player_achievements" | python3 -m json.tool
echo && echo "=== GET player_achievements/$ID_PlayerAchievement ==="
curl -s "$BASE/player_achievements/$ID_PlayerAchievement" | python3 -m json.tool

echo && echo "=== GET tournaments ==="
curl -s "$BASE/tournaments" | python3 -m json.tool
echo && echo "=== GET tournaments/$ID_Tournament ==="
curl -s "$BASE/tournaments/$ID_Tournament" | python3 -m json.tool

echo && echo "=== GET matches ==="
curl -s "$BASE/matches" | python3 -m json.tool
echo && echo "=== GET matches/$ID_Match ==="
curl -s "$BASE/matches/$ID_Match" | python3 -m json.tool

echo && echo "=== GET orders ==="
curl -s "$BASE/orders" | python3 -m json.tool
echo && echo "=== GET orders/$ID_Order ==="
curl -s "$BASE/orders/$ID_Order" | python3 -m json.tool

echo && echo "=== GET tradelistings ==="
curl -s "$BASE/tradelistings" | python3 -m json.tool
echo && echo "=== GET tradelistings/$ID_Tradelisting ==="
curl -s "$BASE/tradelistings/$ID_Tradelisting" | python3 -m json.tool

echo && echo "=== GET draft_participants ==="
curl -s "$BASE/draft_participants" | python3 -m json.tool
echo && echo "=== GET draft_participants/$ID_DraftParticipant ==="
curl -s "$BASE/draft_participants/$ID_DraftParticipant" | python3 -m json.tool

echo && echo "=== GET article_comments ==="
curl -s "$BASE/article_comments" | python3 -m json.tool
echo && echo "=== GET article_comments/$ID_ArticleComment ==="
curl -s "$BASE/article_comments/$ID_ArticleComment" | python3 -m json.tool

echo && echo "=== GET streams ==="
curl -s "$BASE/streams" | python3 -m json.tool
echo && echo "=== GET streams/$ID_Stream ==="
curl -s "$BASE/streams/$ID_Stream" | python3 -m json.tool

echo && echo "=== GET deck_cards ==="
curl -s "$BASE/deck_cards" | python3 -m json.tool
echo && echo "=== GET deck_cards/$ID_DeckCard ==="
curl -s "$BASE/deck_cards/$ID_DeckCard" | python3 -m json.tool

echo && echo "=== GET deck_sideboard_cards ==="
curl -s "$BASE/deck_sideboard_cards" | python3 -m json.tool
echo && echo "=== GET deck_sideboard_cards/$ID_DeckSideboardCard ==="
curl -s "$BASE/deck_sideboard_cards/$ID_DeckSideboardCard" | python3 -m json.tool

echo && echo "=== GET deck_tag_assignments ==="
curl -s "$BASE/deck_tag_assignments" | python3 -m json.tool
echo && echo "=== GET deck_tag_assignments/$ID_DeckTagAssignment ==="
curl -s "$BASE/deck_tag_assignments/$ID_DeckTagAssignment" | python3 -m json.tool

echo && echo "=== GET tournament_judges ==="
curl -s "$BASE/tournament_judges" | python3 -m json.tool
echo && echo "=== GET tournament_judges/$ID_TournamentJudge ==="
curl -s "$BASE/tournament_judges/$ID_TournamentJudge" | python3 -m json.tool

echo && echo "=== GET tournament_registrations ==="
curl -s "$BASE/tournament_registrations" | python3 -m json.tool
echo && echo "=== GET tournament_registrations/$ID_TournamentRegistration ==="
curl -s "$BASE/tournament_registrations/$ID_TournamentRegistration" | python3 -m json.tool

echo && echo "=== GET tournament_prizes ==="
curl -s "$BASE/tournament_prizes" | python3 -m json.tool
echo && echo "=== GET tournament_prizes/$ID_TournamentPrize ==="
curl -s "$BASE/tournament_prizes/$ID_TournamentPrize" | python3 -m json.tool

echo && echo "=== GET tournament_rounds ==="
curl -s "$BASE/tournament_rounds" | python3 -m json.tool
echo && echo "=== GET tournament_rounds/$ID_TournamentRound ==="
curl -s "$BASE/tournament_rounds/$ID_TournamentRound" | python3 -m json.tool

echo && echo "=== GET games ==="
curl -s "$BASE/games" | python3 -m json.tool
echo && echo "=== GET games/$ID_Game ==="
curl -s "$BASE/games/$ID_Game" | python3 -m json.tool

echo && echo "=== GET trade_bids ==="
curl -s "$BASE/trade_bids" | python3 -m json.tool
echo && echo "=== GET trade_bids/$ID_TradeBid ==="
curl -s "$BASE/trade_bids/$ID_TradeBid" | python3 -m json.tool

echo && echo "=== GET trade_transactions ==="
curl -s "$BASE/trade_transactions" | python3 -m json.tool
echo && echo "=== GET trade_transactions/$ID_TradeTransaction ==="
curl -s "$BASE/trade_transactions/$ID_TradeTransaction" | python3 -m json.tool

echo && echo "=== GET draft_sessions ==="
curl -s "$BASE/draft_sessions" | python3 -m json.tool
echo && echo "=== GET draft_sessions/$ID_DraftSession ==="
curl -s "$BASE/draft_sessions/$ID_DraftSession" | python3 -m json.tool

echo && echo "=== GET draft_picks ==="
curl -s "$BASE/draft_picks" | python3 -m json.tool
echo && echo "=== GET draft_picks/$ID_DraftPick ==="
curl -s "$BASE/draft_picks/$ID_DraftPick" | python3 -m json.tool

echo && echo "=== GET articles ==="
curl -s "$BASE/articles" | python3 -m json.tool
echo && echo "=== GET articles/$ID_Article ==="
curl -s "$BASE/articles/$ID_Article" | python3 -m json.tool

echo && echo "=== GET awarded_prizes ==="
curl -s "$BASE/awarded_prizes" | python3 -m json.tool
echo && echo "=== GET awarded_prizes/$ID_AwardedPrize ==="
curl -s "$BASE/awarded_prizes/$ID_AwardedPrize" | python3 -m json.tool

echo && echo "=== GET trade_disputes ==="
curl -s "$BASE/trade_disputes" | python3 -m json.tool
echo && echo "=== GET trade_disputes/$ID_TradeDispute ==="
curl -s "$BASE/trade_disputes/$ID_TradeDispute" | python3 -m json.tool

echo && echo "=== GET article_tag_assignments ==="
curl -s "$BASE/article_tag_assignments" | python3 -m json.tool
echo && echo "=== GET article_tag_assignments/$ID_ArticleTagAssignment ==="
curl -s "$BASE/article_tag_assignments/$ID_ArticleTagAssignment" | python3 -m json.tool
