(* Alcotest tests for DeckCard — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_deck_id = ref 0
let setup_card_set_id = ref 0
let setup_card_id = ref 0
let setup_deck_card_id = ref 0

let do_setup () =
  let* (_, dep_id_player) = post_for_id "/api/players" {json|{
    "public_id": "00000000-0000-0000-0000-000000000001",
    "display_name": "test",
    "rank": "Bronze",
    "rating": 1,
    "peak_rating": 1,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "contact_email": null,
    "win_rate_cached": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  setup_player_id := dep_id_player;
  let dep_body_deck = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"format\": \"Standard\",\n    \"is_public\": false,\n    \"is_tournament_legal\": false,\n    \"archetype\": null,\n    \"wins\": 1,\n    \"losses\": 1,\n    \"draws\": 1,\n    \"player_id\": %d\n  }" !(setup_player_id) in
  let* (_, dep_id_deck) = post_for_id "/api/decks" dep_body_deck in
  setup_deck_id := dep_id_deck;
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
  let dep_body_card = Printf.sprintf "{\n    \"public_id\": \"00000000-0000-0000-0000-000000000001\",\n    \"name\": \"test\",\n    \"card_type\": \"Creature\",\n    \"rarity\": \"Common\",\n    \"mana_cost\": 1,\n    \"mana_colors\": \"White\",\n    \"attack\": 1,\n    \"defense\": 1,\n    \"loyalty\": null,\n    \"description\": \"test\",\n    \"flavor_text\": null,\n    \"image_url\": null,\n    \"artist_name\": null,\n    \"legal_formats\": \"Standard\",\n    \"is_banned\": false,\n    \"is_restricted\": false,\n    \"power_level\": 1,\n    \"metadata\": null,\n    \"total_copies_in_circulation\": 1,\n    \"set_id\": %d\n  }" !(setup_card_set_id) in
  let* (_, dep_id_card) = post_for_id "/api/cards" dep_body_card in
  setup_card_id := dep_id_card;
  let setup_body = Printf.sprintf "{\n    \"quantity\": 2,\n    \"is_commander\": false,\n    \"deck_id\": %d,\n    \"card_id\": %d\n  }" !(setup_deck_id) !(setup_card_id) in
  let* (_, main_id) = post_for_id "/api/deck_cards" setup_body in
  setup_deck_card_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_deck_card () =
  let* code = get "/api/deck_cards" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_deck_card () =
  let create_body = Printf.sprintf "{\n    \"quantity\": 2,\n    \"is_commander\": false,\n    \"deck_id\": %d,\n    \"card_id\": %d\n  }" !(setup_deck_id) !(setup_card_id) in
  let* code = post "/api/deck_cards" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_deck_card () =
  let url = Printf.sprintf "/api/deck_cards/%d" !setup_deck_card_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_deck_card () =
  let url = Printf.sprintf "/api/deck_cards/%d" !setup_deck_card_id in
  let update_body = Printf.sprintf "{\n    \"quantity\": 2,\n    \"is_commander\": false,\n    \"deck_id\": %d,\n    \"card_id\": %d\n  }" !(setup_deck_id) !(setup_card_id) in
  let* code = patch url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_delete_deck_card () =
  let url = Printf.sprintf "/api/deck_cards/%d" !setup_deck_card_id in
  let* code = delete url in
  Alcotest.(check int) "delete returns 204" 204 code;
  Lwt.return_unit

let test_rule_quantity_range () =
  (* Rule: quantity_range — body violates the condition *)
  let body = {json|{
    "quantity": 5,
    "is_commander": false,
    "deck_id": 1,
    "card_id": 1
  }|json} in
  let* code = post "/api/deck_cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_commander_is_singleton () =
  (* Rule: commander_is_singleton — body violates the condition *)
  let body = {json|{
    "quantity": 2,
    "is_commander": true,
    "deck_id": 1,
    "card_id": 1
  }|json} in
  let* code = post "/api/deck_cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_deck_card = [
  Alcotest.test_case "GET /api/deck_cards returns 200" `Quick (lwt_run test_list_deck_card);
  Alcotest.test_case "POST /api/deck_cards returns 201" `Quick (lwt_run test_create_deck_card);
  Alcotest.test_case "GET /api/deck_cards/<id> returns 200" `Quick (lwt_run test_get_deck_card);
  Alcotest.test_case "PATCH /api/deck_cards/<id> returns 200" `Quick (lwt_run test_update_deck_card);
  Alcotest.test_case "DELETE /api/deck_cards/<id> returns 204" `Quick (lwt_run test_delete_deck_card);
  Alcotest.test_case "POST /api/deck_cards rule quantity_range -> 422" `Quick (lwt_run test_rule_quantity_range);
  Alcotest.test_case "POST /api/deck_cards rule commander_is_singleton -> 422" `Quick (lwt_run test_rule_commander_is_singleton);
]

