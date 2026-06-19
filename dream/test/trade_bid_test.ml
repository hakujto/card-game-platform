(* Alcotest tests for TradeBid — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let get ?(headers=[]) url =
  let uri = Uri.of_string (base_url ^ url) in
  let hdrs = Cohttp.Header.of_list headers in
  let* (resp, _body) = Cohttp_lwt_unix.Client.get ~headers:hdrs uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let post ?(headers=[]) url body =
  let uri = Uri.of_string (base_url ^ url) in
  let hdrs = Cohttp.Header.of_list (("Content-Type", "application/json") :: headers) in
  let body_str = Cohttp_lwt.Body.of_string body in
  let* (resp, _body) = Cohttp_lwt_unix.Client.post ~headers:hdrs ~body:body_str uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let put ?(headers=[]) url body =
  let uri = Uri.of_string (base_url ^ url) in
  let hdrs = Cohttp.Header.of_list (("Content-Type", "application/json") :: headers) in
  let body_str = Cohttp_lwt.Body.of_string body in
  let* (resp, _body) = Cohttp_lwt_unix.Client.put ~headers:hdrs ~body:body_str uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let patch ?(headers=[]) url body =
  let uri = Uri.of_string (base_url ^ url) in
  let hdrs = Cohttp.Header.of_list (("Content-Type", "application/json") :: headers) in
  let body_str = Cohttp_lwt.Body.of_string body in
  let* (resp, _body) = Cohttp_lwt_unix.Client.patch ~headers:hdrs ~body:body_str uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let delete ?(headers=[]) url =
  let uri = Uri.of_string (base_url ^ url) in
  let hdrs = Cohttp.Header.of_list headers in
  let* (resp, _body) = Cohttp_lwt_unix.Client.delete ~headers:hdrs uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let post_for_id ?(headers=[]) url body =
  let uri = Uri.of_string (base_url ^ url) in
  let hdrs = Cohttp.Header.of_list (("Content-Type", "application/json") :: headers) in
  let body_str = Cohttp_lwt.Body.of_string body in
  let* (resp, resp_body) = Cohttp_lwt_unix.Client.post ~headers:hdrs ~body:body_str uri in
  let code = Cohttp.Response.status resp |> Cohttp.Code.code_of_status in
  let* body_str = Cohttp_lwt.Body.to_string resp_body in
  let id = if code = 201 then
    (try
      let json = Yojson.Safe.from_string body_str in
      (match Yojson.Safe.Util.member "id" json with
       | `Int i -> i
       | _ -> 0)
    with _ -> 0)
    else 0 in
  Lwt.return (code, id)

let lwt_run f () = Lwt_main.run (f ())

(* setUp: persisted dependency ids — populated once before suite runs *)
let setup_player_id = ref 0
let setup_card_set_id = ref 0
let setup_card_id = ref 0
let setup_trade_listing_id = ref 0
let setup_trade_bid_id = ref 0

let do_setup () =
  let* (_, dep_id_player) = post_for_id "/api/players" {json|{
    "display_name": "test",
    "rank": "Bronze",
    "rating": 1,
    "peak_rating": 1,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  setup_player_id := dep_id_player;
  let* (_, dep_id_card_set) = post_for_id "/api/card_sets" {json|{
    "name": "test",
    "code": "test",
    "release_date": "2024-01-01",
    "rotation_date": null,
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  setup_card_set_id := dep_id_card_set;
  let dep_body_card = Printf.sprintf "{\n    \"name\": \"test\",\n    \"card_type\": \"Creature\",\n    \"rarity\": \"Common\",\n    \"mana_cost\": 1,\n    \"mana_colors\": \"White\",\n    \"attack\": 1,\n    \"defense\": 1,\n    \"loyalty\": null,\n    \"description\": \"test\",\n    \"flavor_text\": null,\n    \"image_url\": null,\n    \"artist_name\": null,\n    \"legal_formats\": \"Standard\",\n    \"is_banned\": false,\n    \"is_restricted\": false,\n    \"power_level\": 1,\n    \"set_id\": %d\n  }" !(setup_card_set_id) in
  let* (_, dep_id_card) = post_for_id "/api/cards" dep_body_card in
  setup_card_id := dep_id_card;
  let dep_body_trade_listing = Printf.sprintf "{\n    \"status\": \"Active\",\n    \"listing_type\": \"FixedPrice\",\n    \"asking_price\": 1.0,\n    \"auction_start_price\": null,\n    \"auction_current_bid\": null,\n    \"auction_end_time\": null,\n    \"foil\": false,\n    \"condition\": \"Mint\",\n    \"quantity\": 1,\n    \"description\": null,\n    \"expires_at\": null,\n    \"seller_id\": %d,\n    \"card_id\": %d\n  }" !(setup_player_id) !(setup_card_id) in
  let* (_, dep_id_trade_listing) = post_for_id "/api/trade_listings" dep_body_trade_listing in
  setup_trade_listing_id := dep_id_trade_listing;
  let setup_body = Printf.sprintf "{\n    \"amount\": 1,\n    \"placed_at\": \"2024-01-01T00:00:00Z\",\n    \"is_winning\": false,\n    \"listing_id\": %d,\n    \"bidder_id\": %d\n  }" !(setup_trade_listing_id) !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/trade_bids" setup_body in
  setup_trade_bid_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_trade_bid () =
  let* code = get "/api/trade_bids" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_trade_bid () =
  let create_body = Printf.sprintf "{\n    \"amount\": 1,\n    \"placed_at\": \"2024-01-01T00:00:00Z\",\n    \"is_winning\": false,\n    \"listing_id\": %d,\n    \"bidder_id\": %d\n  }" !(setup_trade_listing_id) !(setup_player_id) in
  let* code = post "/api/trade_bids" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_trade_bid () =
  let url = Printf.sprintf "/api/trade_bids/%d" !setup_trade_bid_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_amount_positive () =
  (* Rule: amount_positive — body violates the condition *)
  let body = {json|{
    "amount": 0,
    "placed_at": "2024-01-01T00:00:00Z",
    "is_winning": false,
    "listing_id": 1,
    "bidder_id": 1
  }|json} in
  let* code = post "/api/trade_bids" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_trade_bid = [
  Alcotest.test_case "GET /api/trade_bids returns 200" `Quick (lwt_run test_list_trade_bid);
  Alcotest.test_case "POST /api/trade_bids returns 201" `Quick (lwt_run test_create_trade_bid);
  Alcotest.test_case "GET /api/trade_bids/<id> returns 200" `Quick (lwt_run test_get_trade_bid);
  Alcotest.test_case "POST /api/trade_bids rule amount_positive -> 422" `Quick (lwt_run test_rule_amount_positive);
]

