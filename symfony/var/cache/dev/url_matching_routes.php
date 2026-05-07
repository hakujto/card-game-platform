<?php

/**
 * This file has been auto-generated
 * by the Symfony Routing Component.
 */

return [
    false, // $matchHost
    [ // $staticRoutes
        '/api/doc' => [
            [['_route' => 'app.swagger_ui', '_controller' => 'nelmio_api_doc.controller.swagger_ui'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'api_doc_ui', '_controller' => 'App\\Controller\\Api\\ApiIndexController::docUi'], null, ['GET' => 0], null, false, false, null],
        ],
        '/api/doc.json' => [
            [['_route' => 'app.swagger_json', '_controller' => 'nelmio_api_doc.controller.swagger_json'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'api_doc_json', '_controller' => 'App\\Controller\\Api\\ApiIndexController::docJson'], null, ['GET' => 0], null, false, false, null],
        ],
        '/api' => [
            [['_route' => 'api_index', '_controller' => 'App\\Controller\\Api\\ApiIndexController::index'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'api_index_slash', '_controller' => 'App\\Controller\\Api\\ApiIndexController::index'], null, ['GET' => 0], null, true, false, null],
        ],
        '/api/card_abilities' => [
            [['_route' => 'cardAbility_list', '_controller' => 'App\\Controller\\Api\\Cards\\CardAbilityController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'cardAbility_create', '_controller' => 'App\\Controller\\Api\\Cards\\CardAbilityController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/cards' => [
            [['_route' => 'card_list', '_controller' => 'App\\Controller\\Api\\Cards\\CardController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'card_create', '_controller' => 'App\\Controller\\Api\\Cards\\CardController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/card_rulings' => [
            [['_route' => 'cardRuling_list', '_controller' => 'App\\Controller\\Api\\Cards\\CardRulingController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'cardRuling_create', '_controller' => 'App\\Controller\\Api\\Cards\\CardRulingController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/card_sets' => [
            [['_route' => 'cardSet_list', '_controller' => 'App\\Controller\\Api\\Cards\\CardSetController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'cardSet_create', '_controller' => 'App\\Controller\\Api\\Cards\\CardSetController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/deck_cards' => [
            [['_route' => 'deckCard_list', '_controller' => 'App\\Controller\\Api\\Cards\\DeckCardController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'deckCard_create', '_controller' => 'App\\Controller\\Api\\Cards\\DeckCardController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/decks' => [
            [['_route' => 'deck_list', '_controller' => 'App\\Controller\\Api\\Cards\\DeckController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'deck_create', '_controller' => 'App\\Controller\\Api\\Cards\\DeckController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/deck_sideboard_cards' => [
            [['_route' => 'deckSideboardCard_list', '_controller' => 'App\\Controller\\Api\\Cards\\DeckSideboardCardController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'deckSideboardCard_create', '_controller' => 'App\\Controller\\Api\\Cards\\DeckSideboardCardController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/deck_tag_assignments' => [
            [['_route' => 'deckTagAssignment_list', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagAssignmentController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'deckTagAssignment_create', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagAssignmentController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/deck_tags' => [
            [['_route' => 'deckTag_list', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'deckTag_create', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/article_comments' => [
            [['_route' => 'articleComment_list', '_controller' => 'App\\Controller\\Api\\Content\\ArticleCommentController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'articleComment_create', '_controller' => 'App\\Controller\\Api\\Content\\ArticleCommentController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/articles' => [
            [['_route' => 'article_list', '_controller' => 'App\\Controller\\Api\\Content\\ArticleController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'article_create', '_controller' => 'App\\Controller\\Api\\Content\\ArticleController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/article_tag_assignments' => [
            [['_route' => 'articleTagAssignment_list', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagAssignmentController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'articleTagAssignment_create', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagAssignmentController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/article_tags' => [
            [['_route' => 'articleTag_list', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'articleTag_create', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/draft_participants' => [
            [['_route' => 'draftParticipant_list', '_controller' => 'App\\Controller\\Api\\Content\\DraftParticipantController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'draftParticipant_create', '_controller' => 'App\\Controller\\Api\\Content\\DraftParticipantController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/draft_picks' => [
            [['_route' => 'draftPick_list', '_controller' => 'App\\Controller\\Api\\Content\\DraftPickController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'draftPick_create', '_controller' => 'App\\Controller\\Api\\Content\\DraftPickController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/draft_sessions' => [
            [['_route' => 'draftSession_list', '_controller' => 'App\\Controller\\Api\\Content\\DraftSessionController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'draftSession_create', '_controller' => 'App\\Controller\\Api\\Content\\DraftSessionController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/streams' => [
            [['_route' => 'stream_list', '_controller' => 'App\\Controller\\Api\\Content\\StreamController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'stream_create', '_controller' => 'App\\Controller\\Api\\Content\\StreamController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/card_price_histories' => [
            [['_route' => 'cardPriceHistory_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\CardPriceHistoryController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'cardPriceHistory_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\CardPriceHistoryController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/coupons' => [
            [['_route' => 'coupon_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\CouponController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'coupon_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\CouponController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/orders' => [
            [['_route' => 'order_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'order_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/order_items' => [
            [['_route' => 'orderItem_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderItemController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'orderItem_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderItemController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/products' => [
            [['_route' => 'product_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\ProductController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'product_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\ProductController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/trade_bids' => [
            [['_route' => 'tradeBid_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeBidController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tradeBid_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeBidController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/trade_disputes' => [
            [['_route' => 'tradeDispute_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeDisputeController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tradeDispute_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeDisputeController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/trade_transactions' => [
            [['_route' => 'tradeTransaction_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeTransactionController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tradeTransaction_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeTransactionController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/tradelistings' => [
            [['_route' => 'tradelisting_list', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradelistingController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tradelisting_create', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradelistingController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/achievements' => [
            [['_route' => 'achievement_list', '_controller' => 'App\\Controller\\Api\\Players\\AchievementController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'achievement_create', '_controller' => 'App\\Controller\\Api\\Players\\AchievementController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/crafting_ingredients' => [
            [['_route' => 'craftingIngredient_list', '_controller' => 'App\\Controller\\Api\\Players\\CraftingIngredientController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'craftingIngredient_create', '_controller' => 'App\\Controller\\Api\\Players\\CraftingIngredientController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/crafting_recipes' => [
            [['_route' => 'craftingRecipe_list', '_controller' => 'App\\Controller\\Api\\Players\\CraftingRecipeController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'craftingRecipe_create', '_controller' => 'App\\Controller\\Api\\Players\\CraftingRecipeController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/friendships' => [
            [['_route' => 'friendship_list', '_controller' => 'App\\Controller\\Api\\Players\\FriendshipController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'friendship_create', '_controller' => 'App\\Controller\\Api\\Players\\FriendshipController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/player_achievements' => [
            [['_route' => 'playerAchievement_list', '_controller' => 'App\\Controller\\Api\\Players\\PlayerAchievementController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'playerAchievement_create', '_controller' => 'App\\Controller\\Api\\Players\\PlayerAchievementController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/player_collections' => [
            [['_route' => 'playerCollection_list', '_controller' => 'App\\Controller\\Api\\Players\\PlayerCollectionController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'playerCollection_create', '_controller' => 'App\\Controller\\Api\\Players\\PlayerCollectionController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/players' => [
            [['_route' => 'player_list', '_controller' => 'App\\Controller\\Api\\Players\\PlayerController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'player_create', '_controller' => 'App\\Controller\\Api\\Players\\PlayerController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/player_season_statses' => [
            [['_route' => 'playerSeasonStats_list', '_controller' => 'App\\Controller\\Api\\Players\\PlayerSeasonStatsController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'playerSeasonStats_create', '_controller' => 'App\\Controller\\Api\\Players\\PlayerSeasonStatsController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/awarded_prizes' => [
            [['_route' => 'awardedPrize_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\AwardedPrizeController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'awardedPrize_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\AwardedPrizeController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/games' => [
            [['_route' => 'game_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\GameController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'game_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\GameController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/matches' => [
            [['_route' => 'matchRecord_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\MatchRecordController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'matchRecord_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\MatchRecordController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/seasons' => [
            [['_route' => 'season_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\SeasonController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'season_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\SeasonController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/tournaments' => [
            [['_route' => 'tournament_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tournament_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/tournament_judges' => [
            [['_route' => 'tournamentJudge_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentJudgeController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tournamentJudge_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentJudgeController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/tournament_prizes' => [
            [['_route' => 'tournamentPrize_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentPrizeController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tournamentPrize_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentPrizeController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/tournament_registrations' => [
            [['_route' => 'tournamentRegistration_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRegistrationController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tournamentRegistration_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRegistrationController::create'], null, ['POST' => 0], null, false, false, null],
        ],
        '/api/tournament_rounds' => [
            [['_route' => 'tournamentRound_list', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRoundController::list'], null, ['GET' => 0], null, false, false, null],
            [['_route' => 'tournamentRound_create', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRoundController::create'], null, ['POST' => 0], null, false, false, null],
        ],
    ],
    [ // $regexpList
        0 => '{^(?'
                .'|/_error/(\\d+)(?:\\.([^/]++))?(*:35)'
                .'|/api/(?'
                    .'|c(?'
                        .'|ard(?'
                            .'|_(?'
                                .'|abilities/([^/]++)(?'
                                    .'|(*:85)'
                                .')'
                                .'|rulings/([^/]++)(?'
                                    .'|(*:112)'
                                .')'
                                .'|sets/([^/]++)(?'
                                    .'|(*:137)'
                                .')'
                                .'|price_histories/([^/]++)(?'
                                    .'|(*:173)'
                                .')'
                            .')'
                            .'|s/([^/]++)(?'
                                .'|(*:196)'
                            .')'
                        .')'
                        .'|oupons/([^/]++)(?'
                            .'|(*:224)'
                        .')'
                        .'|rafting_(?'
                            .'|ingredients/([^/]++)(?'
                                .'|(*:267)'
                            .')'
                            .'|recipes/([^/]++)(?'
                                .'|(*:295)'
                            .')'
                        .')'
                    .')'
                    .'|d(?'
                        .'|eck(?'
                            .'|_(?'
                                .'|cards/([^/]++)(?'
                                    .'|(*:337)'
                                .')'
                                .'|sideboard_cards/([^/]++)(?'
                                    .'|(*:373)'
                                .')'
                                .'|tag(?'
                                    .'|_assignments/([^/]++)(?'
                                        .'|(*:412)'
                                    .')'
                                    .'|s/([^/]++)(?'
                                        .'|(*:434)'
                                    .')'
                                .')'
                            .')'
                            .'|s/([^/]++)(?'
                                .'|(*:458)'
                            .')'
                        .')'
                        .'|raft_(?'
                            .'|p(?'
                                .'|articipants/([^/]++)(?'
                                    .'|(*:503)'
                                .')'
                                .'|icks/([^/]++)(?'
                                    .'|(*:528)'
                                .')'
                            .')'
                            .'|sessions/([^/]++)(?'
                                .'|(*:558)'
                            .')'
                        .')'
                    .')'
                    .'|a(?'
                        .'|rticle(?'
                            .'|_(?'
                                .'|comments/([^/]++)(?'
                                    .'|(*:606)'
                                .')'
                                .'|tag(?'
                                    .'|_assignments/([^/]++)(?'
                                        .'|(*:645)'
                                    .')'
                                    .'|s/([^/]++)(?'
                                        .'|(*:667)'
                                    .')'
                                .')'
                            .')'
                            .'|s/([^/]++)(?'
                                .'|(*:691)'
                            .')'
                        .')'
                        .'|chievements/([^/]++)(?'
                            .'|(*:724)'
                        .')'
                        .'|warded_prizes/([^/]++)(?'
                            .'|(*:758)'
                        .')'
                    .')'
                    .'|s(?'
                        .'|treams/([^/]++)(?'
                            .'|(*:790)'
                        .')'
                        .'|easons/([^/]++)(?'
                            .'|(*:817)'
                        .')'
                    .')'
                    .'|order(?'
                        .'|s/([^/]++)(?'
                            .'|(*:848)'
                        .')'
                        .'|_items/([^/]++)(?'
                            .'|(*:875)'
                        .')'
                    .')'
                    .'|p(?'
                        .'|roducts/([^/]++)(?'
                            .'|(*:908)'
                        .')'
                        .'|layer(?'
                            .'|_(?'
                                .'|achievements/([^/]++)(?'
                                    .'|(*:953)'
                                .')'
                                .'|collections/([^/]++)(?'
                                    .'|(*:985)'
                                .')'
                                .'|season_statses/([^/]++)(?'
                                    .'|(*:1020)'
                                .')'
                            .')'
                            .'|s/([^/]++)(?'
                                .'|(*:1044)'
                            .')'
                        .')'
                    .')'
                    .'|t(?'
                        .'|rade(?'
                            .'|_(?'
                                .'|bids/([^/]++)(?'
                                    .'|(*:1087)'
                                .')'
                                .'|disputes/([^/]++)(?'
                                    .'|(*:1117)'
                                .')'
                                .'|transactions/([^/]++)(?'
                                    .'|(*:1151)'
                                .')'
                            .')'
                            .'|listings/([^/]++)(?'
                                .'|(*:1182)'
                            .')'
                        .')'
                        .'|ournament(?'
                            .'|s/([^/]++)(?'
                                .'|(*:1218)'
                            .')'
                            .'|_(?'
                                .'|judges/([^/]++)(?'
                                    .'|(*:1250)'
                                .')'
                                .'|prizes/([^/]++)(?'
                                    .'|(*:1278)'
                                .')'
                                .'|r(?'
                                    .'|egistrations/([^/]++)(?'
                                        .'|(*:1316)'
                                    .')'
                                    .'|ounds/([^/]++)(?'
                                        .'|(*:1343)'
                                    .')'
                                .')'
                            .')'
                        .')'
                    .')'
                    .'|friendships/([^/]++)(?'
                        .'|(*:1380)'
                    .')'
                    .'|games/([^/]++)(?'
                        .'|(*:1407)'
                    .')'
                    .'|matches/([^/]++)(?'
                        .'|(*:1436)'
                    .')'
                .')'
            .')/?$}sDu',
    ],
    [ // $dynamicRoutes
        35 => [[['_route' => '_preview_error', '_controller' => 'error_controller::preview', '_format' => 'html'], ['code', '_format'], null, null, false, true, null]],
        85 => [
            [['_route' => 'cardAbility_show', '_controller' => 'App\\Controller\\Api\\Cards\\CardAbilityController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'cardAbility_update', '_controller' => 'App\\Controller\\Api\\Cards\\CardAbilityController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'cardAbility_delete', '_controller' => 'App\\Controller\\Api\\Cards\\CardAbilityController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        112 => [
            [['_route' => 'cardRuling_show', '_controller' => 'App\\Controller\\Api\\Cards\\CardRulingController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'cardRuling_update', '_controller' => 'App\\Controller\\Api\\Cards\\CardRulingController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'cardRuling_delete', '_controller' => 'App\\Controller\\Api\\Cards\\CardRulingController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        137 => [
            [['_route' => 'cardSet_show', '_controller' => 'App\\Controller\\Api\\Cards\\CardSetController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'cardSet_update', '_controller' => 'App\\Controller\\Api\\Cards\\CardSetController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'cardSet_delete', '_controller' => 'App\\Controller\\Api\\Cards\\CardSetController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        173 => [
            [['_route' => 'cardPriceHistory_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\CardPriceHistoryController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'cardPriceHistory_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\CardPriceHistoryController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'cardPriceHistory_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\CardPriceHistoryController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        196 => [
            [['_route' => 'card_show', '_controller' => 'App\\Controller\\Api\\Cards\\CardController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'card_update', '_controller' => 'App\\Controller\\Api\\Cards\\CardController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'card_delete', '_controller' => 'App\\Controller\\Api\\Cards\\CardController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        224 => [
            [['_route' => 'coupon_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\CouponController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'coupon_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\CouponController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'coupon_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\CouponController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        267 => [
            [['_route' => 'craftingIngredient_show', '_controller' => 'App\\Controller\\Api\\Players\\CraftingIngredientController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'craftingIngredient_update', '_controller' => 'App\\Controller\\Api\\Players\\CraftingIngredientController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'craftingIngredient_delete', '_controller' => 'App\\Controller\\Api\\Players\\CraftingIngredientController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        295 => [
            [['_route' => 'craftingRecipe_show', '_controller' => 'App\\Controller\\Api\\Players\\CraftingRecipeController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'craftingRecipe_update', '_controller' => 'App\\Controller\\Api\\Players\\CraftingRecipeController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'craftingRecipe_delete', '_controller' => 'App\\Controller\\Api\\Players\\CraftingRecipeController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        337 => [
            [['_route' => 'deckCard_show', '_controller' => 'App\\Controller\\Api\\Cards\\DeckCardController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'deckCard_update', '_controller' => 'App\\Controller\\Api\\Cards\\DeckCardController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'deckCard_delete', '_controller' => 'App\\Controller\\Api\\Cards\\DeckCardController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        373 => [
            [['_route' => 'deckSideboardCard_show', '_controller' => 'App\\Controller\\Api\\Cards\\DeckSideboardCardController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'deckSideboardCard_update', '_controller' => 'App\\Controller\\Api\\Cards\\DeckSideboardCardController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'deckSideboardCard_delete', '_controller' => 'App\\Controller\\Api\\Cards\\DeckSideboardCardController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        412 => [
            [['_route' => 'deckTagAssignment_show', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagAssignmentController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'deckTagAssignment_update', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagAssignmentController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'deckTagAssignment_delete', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagAssignmentController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        434 => [
            [['_route' => 'deckTag_show', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'deckTag_update', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'deckTag_delete', '_controller' => 'App\\Controller\\Api\\Cards\\DeckTagController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        458 => [
            [['_route' => 'deck_show', '_controller' => 'App\\Controller\\Api\\Cards\\DeckController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'deck_update', '_controller' => 'App\\Controller\\Api\\Cards\\DeckController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'deck_delete', '_controller' => 'App\\Controller\\Api\\Cards\\DeckController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        503 => [
            [['_route' => 'draftParticipant_show', '_controller' => 'App\\Controller\\Api\\Content\\DraftParticipantController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'draftParticipant_update', '_controller' => 'App\\Controller\\Api\\Content\\DraftParticipantController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'draftParticipant_delete', '_controller' => 'App\\Controller\\Api\\Content\\DraftParticipantController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        528 => [
            [['_route' => 'draftPick_show', '_controller' => 'App\\Controller\\Api\\Content\\DraftPickController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'draftPick_update', '_controller' => 'App\\Controller\\Api\\Content\\DraftPickController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'draftPick_delete', '_controller' => 'App\\Controller\\Api\\Content\\DraftPickController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        558 => [
            [['_route' => 'draftSession_show', '_controller' => 'App\\Controller\\Api\\Content\\DraftSessionController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'draftSession_update', '_controller' => 'App\\Controller\\Api\\Content\\DraftSessionController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'draftSession_delete', '_controller' => 'App\\Controller\\Api\\Content\\DraftSessionController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        606 => [
            [['_route' => 'articleComment_show', '_controller' => 'App\\Controller\\Api\\Content\\ArticleCommentController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'articleComment_update', '_controller' => 'App\\Controller\\Api\\Content\\ArticleCommentController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'articleComment_delete', '_controller' => 'App\\Controller\\Api\\Content\\ArticleCommentController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        645 => [
            [['_route' => 'articleTagAssignment_show', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagAssignmentController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'articleTagAssignment_update', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagAssignmentController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'articleTagAssignment_delete', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagAssignmentController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        667 => [
            [['_route' => 'articleTag_show', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'articleTag_update', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'articleTag_delete', '_controller' => 'App\\Controller\\Api\\Content\\ArticleTagController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        691 => [
            [['_route' => 'article_show', '_controller' => 'App\\Controller\\Api\\Content\\ArticleController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'article_update', '_controller' => 'App\\Controller\\Api\\Content\\ArticleController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'article_delete', '_controller' => 'App\\Controller\\Api\\Content\\ArticleController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        724 => [
            [['_route' => 'achievement_show', '_controller' => 'App\\Controller\\Api\\Players\\AchievementController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'achievement_update', '_controller' => 'App\\Controller\\Api\\Players\\AchievementController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'achievement_delete', '_controller' => 'App\\Controller\\Api\\Players\\AchievementController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        758 => [
            [['_route' => 'awardedPrize_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\AwardedPrizeController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'awardedPrize_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\AwardedPrizeController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'awardedPrize_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\AwardedPrizeController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        790 => [
            [['_route' => 'stream_show', '_controller' => 'App\\Controller\\Api\\Content\\StreamController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'stream_update', '_controller' => 'App\\Controller\\Api\\Content\\StreamController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'stream_delete', '_controller' => 'App\\Controller\\Api\\Content\\StreamController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        817 => [
            [['_route' => 'season_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\SeasonController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'season_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\SeasonController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'season_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\SeasonController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        848 => [
            [['_route' => 'order_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'order_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'order_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        875 => [
            [['_route' => 'orderItem_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderItemController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'orderItem_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderItemController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'orderItem_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\OrderItemController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        908 => [
            [['_route' => 'product_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\ProductController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'product_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\ProductController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'product_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\ProductController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        953 => [
            [['_route' => 'playerAchievement_show', '_controller' => 'App\\Controller\\Api\\Players\\PlayerAchievementController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'playerAchievement_update', '_controller' => 'App\\Controller\\Api\\Players\\PlayerAchievementController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'playerAchievement_delete', '_controller' => 'App\\Controller\\Api\\Players\\PlayerAchievementController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        985 => [
            [['_route' => 'playerCollection_show', '_controller' => 'App\\Controller\\Api\\Players\\PlayerCollectionController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'playerCollection_update', '_controller' => 'App\\Controller\\Api\\Players\\PlayerCollectionController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'playerCollection_delete', '_controller' => 'App\\Controller\\Api\\Players\\PlayerCollectionController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1020 => [
            [['_route' => 'playerSeasonStats_show', '_controller' => 'App\\Controller\\Api\\Players\\PlayerSeasonStatsController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'playerSeasonStats_update', '_controller' => 'App\\Controller\\Api\\Players\\PlayerSeasonStatsController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'playerSeasonStats_delete', '_controller' => 'App\\Controller\\Api\\Players\\PlayerSeasonStatsController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1044 => [
            [['_route' => 'player_show', '_controller' => 'App\\Controller\\Api\\Players\\PlayerController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'player_update', '_controller' => 'App\\Controller\\Api\\Players\\PlayerController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'player_delete', '_controller' => 'App\\Controller\\Api\\Players\\PlayerController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1087 => [
            [['_route' => 'tradeBid_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeBidController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tradeBid_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeBidController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tradeBid_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeBidController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1117 => [
            [['_route' => 'tradeDispute_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeDisputeController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tradeDispute_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeDisputeController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tradeDispute_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeDisputeController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1151 => [
            [['_route' => 'tradeTransaction_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeTransactionController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tradeTransaction_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeTransactionController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tradeTransaction_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradeTransactionController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1182 => [
            [['_route' => 'tradelisting_show', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradelistingController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tradelisting_update', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradelistingController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tradelisting_delete', '_controller' => 'App\\Controller\\Api\\Marketplace\\TradelistingController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1218 => [
            [['_route' => 'tournament_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tournament_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tournament_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1250 => [
            [['_route' => 'tournamentJudge_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentJudgeController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tournamentJudge_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentJudgeController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tournamentJudge_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentJudgeController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1278 => [
            [['_route' => 'tournamentPrize_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentPrizeController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tournamentPrize_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentPrizeController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tournamentPrize_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentPrizeController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1316 => [
            [['_route' => 'tournamentRegistration_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRegistrationController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tournamentRegistration_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRegistrationController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tournamentRegistration_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRegistrationController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1343 => [
            [['_route' => 'tournamentRound_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRoundController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'tournamentRound_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRoundController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'tournamentRound_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\TournamentRoundController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1380 => [
            [['_route' => 'friendship_show', '_controller' => 'App\\Controller\\Api\\Players\\FriendshipController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'friendship_update', '_controller' => 'App\\Controller\\Api\\Players\\FriendshipController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'friendship_delete', '_controller' => 'App\\Controller\\Api\\Players\\FriendshipController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1407 => [
            [['_route' => 'game_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\GameController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'game_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\GameController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'game_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\GameController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
        ],
        1436 => [
            [['_route' => 'matchRecord_show', '_controller' => 'App\\Controller\\Api\\Tournaments\\MatchRecordController::show'], ['id'], ['GET' => 0], null, false, true, null],
            [['_route' => 'matchRecord_update', '_controller' => 'App\\Controller\\Api\\Tournaments\\MatchRecordController::update'], ['id'], ['PUT' => 0, 'PATCH' => 1], null, false, true, null],
            [['_route' => 'matchRecord_delete', '_controller' => 'App\\Controller\\Api\\Tournaments\\MatchRecordController::delete'], ['id'], ['DELETE' => 0], null, false, true, null],
            [null, null, null, null, false, false, 0],
        ],
    ],
    null, // $checkCondition
];
