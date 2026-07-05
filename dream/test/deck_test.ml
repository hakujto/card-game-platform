(* Alcotest tests for Deck — uses cohttp-lwt-unix for HTTP requests *)
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
  let setup_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"format\": \"Standard\",\n    \"is_public\": false,\n    \"is_tournament_legal\": false,\n    \"archetype\": null,\n    \"wins\": 0,\n    \"losses\": 0,\n    \"draws\": 0,\n    \"player_id\": %d\n  }" !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/decks" setup_body in
  setup_deck_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_deck () =
  let* code = get "/api/decks" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_deck () =
  let* code = get "/api/decks?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_deck () =
  let create_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"format\": \"Standard\",\n    \"is_public\": false,\n    \"is_tournament_legal\": false,\n    \"archetype\": null,\n    \"wins\": 0,\n    \"losses\": 0,\n    \"draws\": 0,\n    \"player_id\": %d\n  }" !(setup_player_id) in
  let* code = post "/api/decks" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_deck () =
  let url = Printf.sprintf "/api/decks/%d" !setup_deck_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_deck () =
  let url = Printf.sprintf "/api/decks/%d" !setup_deck_id in
  let update_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"format\": \"Standard\",\n    \"is_public\": false,\n    \"is_tournament_legal\": false,\n    \"archetype\": null,\n    \"wins\": 0,\n    \"losses\": 0,\n    \"draws\": 0,\n    \"player_id\": %d\n  }" !(setup_player_id) in
  let* code = put url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_patch_safe_deck () =
  (* @patch_safe: send only "name" in partial update *)
  let* code = patch "/api/decks/1" {json|{"name": "test"}|json} in
  Alcotest.(check bool) "patch_safe returns 200 or 404 or 400" true (code = 200 || code = 404 || code = 400);
  Lwt.return_unit

let test_delete_deck () =
  let url = Printf.sprintf "/api/decks/%d" !setup_deck_id in
  let* code = delete url in
  Alcotest.(check int) "delete returns 204" 204 code;
  Lwt.return_unit

let test_rule_wins_not_negative () =
  (* Rule: wins_not_negative — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "format": "Standard",
    "is_public": false,
    "is_tournament_legal": false,
    "archetype": null,
    "wins": -1,
    "losses": 0,
    "draws": 0,
    "player_id": 1
  }|json} in
  let* code = post "/api/decks" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_losses_not_negative () =
  (* Rule: losses_not_negative — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "format": "Standard",
    "is_public": false,
    "is_tournament_legal": false,
    "archetype": null,
    "wins": 0,
    "losses": -1,
    "draws": 0,
    "player_id": 1
  }|json} in
  let* code = post "/api/decks" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_draws_not_negative () =
  (* Rule: draws_not_negative — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "format": "Standard",
    "is_public": false,
    "is_tournament_legal": false,
    "archetype": null,
    "wins": 0,
    "losses": 0,
    "draws": -1,
    "player_id": 1
  }|json} in
  let* code = post "/api/decks" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_tournament_legal_deck_must_be_validated () =
  (* Rule: tournament_legal_deck_must_be_validated — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "format": "Standard",
    "is_public": false,
    "is_tournament_legal": true,
    "archetype": null,
    "wins": 0,
    "losses": 0,
    "draws": 0,
    "player_id": 1
  }|json} in
  let* code = post "/api/decks" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_deck = [
  Alcotest.test_case "GET /api/decks returns 200" `Quick (lwt_run test_list_deck);
  Alcotest.test_case "GET /api/decks?q=test returns 200" `Quick (lwt_run test_search_deck);
  Alcotest.test_case "POST /api/decks returns 201" `Quick (lwt_run test_create_deck);
  Alcotest.test_case "GET /api/decks/<id> returns 200" `Quick (lwt_run test_get_deck);
  Alcotest.test_case "PUT /api/decks/<id> returns 200" `Quick (lwt_run test_update_deck);
  Alcotest.test_case "PATCH /api/decks/1 patch_safe field" `Quick (lwt_run test_patch_safe_deck);
  Alcotest.test_case "DELETE /api/decks/<id> returns 204" `Quick (lwt_run test_delete_deck);
  Alcotest.test_case "POST /api/decks rule wins_not_negative -> 422" `Quick (lwt_run test_rule_wins_not_negative);
  Alcotest.test_case "POST /api/decks rule losses_not_negative -> 422" `Quick (lwt_run test_rule_losses_not_negative);
  Alcotest.test_case "POST /api/decks rule draws_not_negative -> 422" `Quick (lwt_run test_rule_draws_not_negative);
  Alcotest.test_case "POST /api/decks rule tournament_legal_deck_must_be_validated -> 422" `Quick (lwt_run test_rule_tournament_legal_deck_must_be_validated);
]

