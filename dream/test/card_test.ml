(* Alcotest tests for Card — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_card_set_id = ref 0
let setup_card_id = ref 0

let do_setup () =
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
  let setup_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"card_type\": \"not_Creature\",\n    \"rarity\": \"Common\",\n    \"mana_cost\": 10,\n    \"mana_colors\": \"White\",\n    \"attack\": 1,\n    \"defense\": 1,\n    \"description\": \"test\",\n    \"flavor_text\": null,\n    \"image_url\": null,\n    \"artist_name\": null,\n    \"legal_formats\": \"Standard\",\n    \"is_banned\": false,\n    \"is_restricted\": false,\n    \"power_level\": 5,\n    \"set_id\": %d\n  }" !(setup_card_set_id) in
  let* (_, main_id) = post_for_id "/api/cards" setup_body in
  setup_card_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_card () =
  let* code = get "/api/cards" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_card () =
  let* code = get "/api/cards?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_card () =
  let create_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"card_type\": \"not_Creature\",\n    \"rarity\": \"Common\",\n    \"mana_cost\": 10,\n    \"mana_colors\": \"White\",\n    \"attack\": 1,\n    \"defense\": 1,\n    \"description\": \"test\",\n    \"flavor_text\": null,\n    \"image_url\": null,\n    \"artist_name\": null,\n    \"legal_formats\": \"Standard\",\n    \"is_banned\": false,\n    \"is_restricted\": false,\n    \"power_level\": 5,\n    \"set_id\": %d\n  }" !(setup_card_set_id) in
  let* code = post "/api/cards" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_card () =
  let url = Printf.sprintf "/api/cards/%d" !setup_card_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_card () =
  let url = Printf.sprintf "/api/cards/%d" !setup_card_id in
  let update_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"card_type\": \"not_Creature\",\n    \"rarity\": \"Common\",\n    \"mana_cost\": 10,\n    \"mana_colors\": \"White\",\n    \"attack\": 1,\n    \"defense\": 1,\n    \"description\": \"test\",\n    \"flavor_text\": null,\n    \"image_url\": null,\n    \"artist_name\": null,\n    \"legal_formats\": \"Standard\",\n    \"is_banned\": false,\n    \"is_restricted\": false,\n    \"power_level\": 5,\n    \"set_id\": %d\n  }" !(setup_card_set_id) in
  let* code = put url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_rule_creature_requires_stats () =
  (* Rule: creature_requires_stats — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_planeswalker_requires_loyalty () =
  (* Rule: planeswalker_requires_loyalty — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "Planeswalker",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_land_has_no_mana_cost () =
  (* Rule: land_has_no_mana_cost — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "Land",
    "rarity": "Common",
    "mana_cost": 1,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_spell_or_artifact_no_loyalty () =
  (* Rule: spell_or_artifact_no_loyalty — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "loyalty": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_mana_cost_range () =
  (* Rule: mana_cost_range — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 21,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_power_level_range () =
  (* Rule: power_level_range — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 11,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_not_banned_and_restricted () =
  (* Rule: not_banned_and_restricted — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": true,
    "is_restricted": true,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_banned_card_not_in_legal_formats () =
  (* Rule: banned_card_not_in_legal_formats — body violates the condition *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": 1,
    "defense": 1,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "not_message",
    "is_banned": true,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json} in
  let* code = post "/api/cards" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_card = [
  Alcotest.test_case "GET /api/cards returns 200" `Quick (lwt_run test_list_card);
  Alcotest.test_case "GET /api/cards?q=test returns 200" `Quick (lwt_run test_search_card);
  Alcotest.test_case "POST /api/cards returns 201" `Quick (lwt_run test_create_card);
  Alcotest.test_case "GET /api/cards/<id> returns 200" `Quick (lwt_run test_get_card);
  Alcotest.test_case "PUT /api/cards/<id> returns 200" `Quick (lwt_run test_update_card);
  Alcotest.test_case "POST /api/cards rule creature_requires_stats -> 422" `Quick (lwt_run test_rule_creature_requires_stats);
  Alcotest.test_case "POST /api/cards rule planeswalker_requires_loyalty -> 422" `Quick (lwt_run test_rule_planeswalker_requires_loyalty);
  Alcotest.test_case "POST /api/cards rule land_has_no_mana_cost -> 422" `Quick (lwt_run test_rule_land_has_no_mana_cost);
  Alcotest.test_case "POST /api/cards rule spell_or_artifact_no_loyalty -> 422" `Quick (lwt_run test_rule_spell_or_artifact_no_loyalty);
  Alcotest.test_case "POST /api/cards rule mana_cost_range -> 422" `Quick (lwt_run test_rule_mana_cost_range);
  Alcotest.test_case "POST /api/cards rule power_level_range -> 422" `Quick (lwt_run test_rule_power_level_range);
  Alcotest.test_case "POST /api/cards rule not_banned_and_restricted -> 422" `Quick (lwt_run test_rule_not_banned_and_restricted);
  Alcotest.test_case "POST /api/cards rule banned_card_not_in_legal_formats -> 422" `Quick (lwt_run test_rule_banned_card_not_in_legal_formats);
]

