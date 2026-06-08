(* Run all Alcotest suites *)
let () =
  Alcotest.run "CardsProject API Tests" [
    ("card", Card_test.suite_card);
    ("card_set", Card_set_test.suite_card_set);
    ("card_ruling", Card_ruling_test.suite_card_ruling);
    ("card_ability", Card_ability_test.suite_card_ability);
    ("deck", Deck_test.suite_deck);
    ("deck_card", Deck_card_test.suite_deck_card);
    ("deck_sideboard_card", Deck_sideboard_card_test.suite_deck_sideboard_card);
    ("deck_tag", Deck_tag_test.suite_deck_tag);
    ("deck_tag_assignment", Deck_tag_assignment_test.suite_deck_tag_assignment);
    ("player", Player_test.suite_player);
    ("player_season_stats", Player_season_stats_test.suite_player_season_stats);
    ("player_collection", Player_collection_test.suite_player_collection);
    ("friendship", Friendship_test.suite_friendship);
    ("achievement", Achievement_test.suite_achievement);
    ("player_achievement", Player_achievement_test.suite_player_achievement);
    ("crafting_recipe", Crafting_recipe_test.suite_crafting_recipe);
    ("crafting_ingredient", Crafting_ingredient_test.suite_crafting_ingredient);
    ("season", Season_test.suite_season);
    ("tournament", Tournament_test.suite_tournament);
    ("tournament_judge", Tournament_judge_test.suite_tournament_judge);
    ("tournament_registration", Tournament_registration_test.suite_tournament_registration);
    ("tournament_round", Tournament_round_test.suite_tournament_round);
    ("match", Match_test.suite_match);
    ("game", Game_test.suite_game);
    ("tournament_prize", Tournament_prize_test.suite_tournament_prize);
    ("awarded_prize", Awarded_prize_test.suite_awarded_prize);
    ("product", Product_test.suite_product);
    ("order", Order_test.suite_order);
    ("order_item", Order_item_test.suite_order_item);
    ("coupon", Coupon_test.suite_coupon);
    ("trade_listing", Trade_listing_test.suite_trade_listing);
    ("trade_bid", Trade_bid_test.suite_trade_bid);
    ("trade_transaction", Trade_transaction_test.suite_trade_transaction);
    ("card_price_history", Card_price_history_test.suite_card_price_history);
    ("trade_dispute", Trade_dispute_test.suite_trade_dispute);
    ("draft_session", Draft_session_test.suite_draft_session);
    ("draft_participant", Draft_participant_test.suite_draft_participant);
    ("draft_pick", Draft_pick_test.suite_draft_pick);
    ("article", Article_test.suite_article);
    ("article_tag", Article_tag_test.suite_article_tag);
    ("article_tag_assignment", Article_tag_assignment_test.suite_article_tag_assignment);
    ("article_comment", Article_comment_test.suite_article_comment);
    ("stream", Stream_test.suite_stream);
  ]
