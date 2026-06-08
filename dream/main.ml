(* Dream application — CardsProject *)
open Lwt.Syntax

let db_url = "sqlite3:cards_project.db"

let make_handler req =
  let* conn = Caqti_lwt_unix.connect (Uri.of_string db_url) in
  (match conn with
   | Error e ->
     Dream.respond ~status:`Internal_Server_Error
       ~headers:[("Content-Type","application/json")]
       (Printf.sprintf {json|{"error":"%s"}|json} (Caqti_error.show e))
   | Ok db ->
     let target_path = match String.index_opt (Dream.target req) '?' with
       | Some i -> String.sub (Dream.target req) 0 i
       | None -> Dream.target req
     in
     let path = String.split_on_char '/' target_path
       |> List.filter (fun s -> s <> "") in
     (match path with
      | "api" :: "cards" :: _ -> Cards_project_lib.Card_handler.handler_card db req
      | "api" :: "card_sets" :: _ -> Cards_project_lib.Card_set_handler.handler_card_set db req
      | "api" :: "card_rulings" :: _ -> Cards_project_lib.Card_ruling_handler.handler_card_ruling db req
      | "api" :: "card_abilities" :: _ -> Cards_project_lib.Card_ability_handler.handler_card_ability db req
      | "api" :: "decks" :: _ -> Cards_project_lib.Deck_handler.handler_deck db req
      | "api" :: "deck_cards" :: _ -> Cards_project_lib.Deck_card_handler.handler_deck_card db req
      | "api" :: "deck_sideboard_cards" :: _ -> Cards_project_lib.Deck_sideboard_card_handler.handler_deck_sideboard_card db req
      | "api" :: "deck_tags" :: _ -> Cards_project_lib.Deck_tag_handler.handler_deck_tag db req
      | "api" :: "deck_tag_assignments" :: _ -> Cards_project_lib.Deck_tag_assignment_handler.handler_deck_tag_assignment db req
      | "api" :: "players" :: _ -> Cards_project_lib.Player_handler.handler_player db req
      | "api" :: "player_season_statses" :: _ -> Cards_project_lib.Player_season_stats_handler.handler_player_season_stats db req
      | "api" :: "player_collections" :: _ -> Cards_project_lib.Player_collection_handler.handler_player_collection db req
      | "api" :: "friendships" :: _ -> Cards_project_lib.Friendship_handler.handler_friendship db req
      | "api" :: "achievements" :: _ -> Cards_project_lib.Achievement_handler.handler_achievement db req
      | "api" :: "player_achievements" :: _ -> Cards_project_lib.Player_achievement_handler.handler_player_achievement db req
      | "api" :: "crafting_recipes" :: _ -> Cards_project_lib.Crafting_recipe_handler.handler_crafting_recipe db req
      | "api" :: "crafting_ingredients" :: _ -> Cards_project_lib.Crafting_ingredient_handler.handler_crafting_ingredient db req
      | "api" :: "seasons" :: _ -> Cards_project_lib.Season_handler.handler_season db req
      | "api" :: "tournaments" :: _ -> Cards_project_lib.Tournament_handler.handler_tournament db req
      | "api" :: "tournament_judges" :: _ -> Cards_project_lib.Tournament_judge_handler.handler_tournament_judge db req
      | "api" :: "tournament_registrations" :: _ -> Cards_project_lib.Tournament_registration_handler.handler_tournament_registration db req
      | "api" :: "tournament_rounds" :: _ -> Cards_project_lib.Tournament_round_handler.handler_tournament_round db req
      | "api" :: "matches" :: _ -> Cards_project_lib.Match_handler.handler_match db req
      | "api" :: "games" :: _ -> Cards_project_lib.Game_handler.handler_game db req
      | "api" :: "tournament_prizes" :: _ -> Cards_project_lib.Tournament_prize_handler.handler_tournament_prize db req
      | "api" :: "awarded_prizes" :: _ -> Cards_project_lib.Awarded_prize_handler.handler_awarded_prize db req
      | "api" :: "products" :: _ -> Cards_project_lib.Product_handler.handler_product db req
      | "api" :: "orders" :: _ -> Cards_project_lib.Order_handler.handler_order db req
      | "api" :: "order_items" :: _ -> Cards_project_lib.Order_item_handler.handler_order_item db req
      | "api" :: "coupons" :: _ -> Cards_project_lib.Coupon_handler.handler_coupon db req
      | "api" :: "trade_listings" :: _ -> Cards_project_lib.Trade_listing_handler.handler_trade_listing db req
      | "api" :: "trade_bids" :: _ -> Cards_project_lib.Trade_bid_handler.handler_trade_bid db req
      | "api" :: "trade_transactions" :: _ -> Cards_project_lib.Trade_transaction_handler.handler_trade_transaction db req
      | "api" :: "card_price_histories" :: _ -> Cards_project_lib.Card_price_history_handler.handler_card_price_history db req
      | "api" :: "trade_disputes" :: _ -> Cards_project_lib.Trade_dispute_handler.handler_trade_dispute db req
      | "api" :: "draft_sessions" :: _ -> Cards_project_lib.Draft_session_handler.handler_draft_session db req
      | "api" :: "draft_participants" :: _ -> Cards_project_lib.Draft_participant_handler.handler_draft_participant db req
      | "api" :: "draft_picks" :: _ -> Cards_project_lib.Draft_pick_handler.handler_draft_pick db req
      | "api" :: "articles" :: _ -> Cards_project_lib.Article_handler.handler_article db req
      | "api" :: "article_tags" :: _ -> Cards_project_lib.Article_tag_handler.handler_article_tag db req
      | "api" :: "article_tag_assignments" :: _ -> Cards_project_lib.Article_tag_assignment_handler.handler_article_tag_assignment db req
      | "api" :: "article_comments" :: _ -> Cards_project_lib.Article_comment_handler.handler_article_comment db req
      | "api" :: "streams" :: _ -> Cards_project_lib.Stream_handler.handler_stream db req
      | _ -> Dream.respond ~status:`Not_Found
               ~headers:[("Content-Type","application/json")]
               {json|{"error":"not found"}|json}))

let () =
  Dream.run ~interface:"127.0.0.1" ~port:3000
  @@ Dream.logger
  @@ make_handler
