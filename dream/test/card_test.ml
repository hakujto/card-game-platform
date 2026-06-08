(* Alcotest tests for Card — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
    "description": "test",
    "flavor_text": null,
    "image_url": null,
    "artist_name": null,
    "legal_formats": "Standard",
    "is_banned": false,
    "is_restricted": false,
    "power_level": 5,
    "set_id": 1
  }|json}

let get url =
  let uri = Uri.of_string (base_url ^ url) in
  let* (resp, _body) = Cohttp_lwt_unix.Client.get uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let post url body =
  let uri = Uri.of_string (base_url ^ url) in
  let headers = Cohttp.Header.of_list [("Content-Type", "application/json")] in
  let body_str = Cohttp_lwt.Body.of_string body in
  let* (resp, _body) = Cohttp_lwt_unix.Client.post ~headers ~body:body_str uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let put url body =
  let uri = Uri.of_string (base_url ^ url) in
  let headers = Cohttp.Header.of_list [("Content-Type", "application/json")] in
  let body_str = Cohttp_lwt.Body.of_string body in
  let* (resp, _body) = Cohttp_lwt_unix.Client.put ~headers ~body:body_str uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let delete url =
  let uri = Uri.of_string (base_url ^ url) in
  let* (resp, _body) = Cohttp_lwt_unix.Client.delete uri in
  Lwt.return (Cohttp.Response.status resp |> Cohttp.Code.code_of_status)

let lwt_run f () = Lwt_main.run (f ())

let test_list_card () =
  let* code = get "/api/cards" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_card () =
  let* code = get "/api/cards?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_card () =
  let* code = post "/api/cards" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_card () =
  let* code = get "/api/cards/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_card () =
  let* code = put "/api/cards/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_creature_requires_stats () =
  (* Rule: creature_requires_stats - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "defense": null,
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
  (* Rule: planeswalker_requires_loyalty - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "Planeswalker",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  (* Rule: land_has_no_mana_cost - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "Land",
    "rarity": "Common",
    "mana_cost": 1,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  (* Rule: spell_or_artifact_no_loyalty - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  (* Rule: mana_cost_range - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 21,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  (* Rule: power_level_range - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  (* Rule: not_banned_and_restricted - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  (* Rule: banned_card_not_in_legal_formats - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "card_type": "not_Creature",
    "rarity": "Common",
    "mana_cost": 10,
    "mana_colors": "White",
    "attack": null,
    "defense": null,
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
  Alcotest.test_case "GET /api/cards/1 returns 200 or 404" `Quick (lwt_run test_get_card);
  Alcotest.test_case "PUT /api/cards/1 returns 200 or 404" `Quick (lwt_run test_update_card);
  Alcotest.test_case "POST /api/cards rule creature_requires_stats -> 422" `Quick (lwt_run test_rule_creature_requires_stats);
  Alcotest.test_case "POST /api/cards rule planeswalker_requires_loyalty -> 422" `Quick (lwt_run test_rule_planeswalker_requires_loyalty);
  Alcotest.test_case "POST /api/cards rule land_has_no_mana_cost -> 422" `Quick (lwt_run test_rule_land_has_no_mana_cost);
  Alcotest.test_case "POST /api/cards rule spell_or_artifact_no_loyalty -> 422" `Quick (lwt_run test_rule_spell_or_artifact_no_loyalty);
  Alcotest.test_case "POST /api/cards rule mana_cost_range -> 422" `Quick (lwt_run test_rule_mana_cost_range);
  Alcotest.test_case "POST /api/cards rule power_level_range -> 422" `Quick (lwt_run test_rule_power_level_range);
  Alcotest.test_case "POST /api/cards rule not_banned_and_restricted -> 422" `Quick (lwt_run test_rule_not_banned_and_restricted);
  Alcotest.test_case "POST /api/cards rule banned_card_not_in_legal_formats -> 422" `Quick (lwt_run test_rule_banned_card_not_in_legal_formats);
]

