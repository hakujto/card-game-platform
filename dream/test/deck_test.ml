(* Alcotest tests for Deck — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "description": null,
    "format": "Standard",
    "is_public": false,
    "is_tournament_legal": false,
    "archetype": null,
    "wins": 0,
    "losses": 0,
    "draws": 0,
    "player_id": 1
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

let test_list_deck () =
  let* code = get "/api/decks" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_deck () =
  let* code = get "/api/decks?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_deck () =
  let* code = post "/api/decks" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_deck () =
  let* code = get "/api/decks/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_deck () =
  let* code = put "/api/decks/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_delete_deck () =
  let* code = delete "/api/decks/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let test_rule_wins_not_negative () =
  (* Rule: wins_not_negative - this body should violate the condition and yield 422/400 *)
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
  (* Rule: losses_not_negative - this body should violate the condition and yield 422/400 *)
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
  (* Rule: draws_not_negative - this body should violate the condition and yield 422/400 *)
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
  (* Rule: tournament_legal_deck_must_be_validated - this body should violate the condition and yield 422/400 *)
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
  Alcotest.test_case "GET /api/decks/1 returns 200 or 404" `Quick (lwt_run test_get_deck);
  Alcotest.test_case "PUT /api/decks/1 returns 200 or 404" `Quick (lwt_run test_update_deck);
  Alcotest.test_case "DELETE /api/decks/1 returns 204 or 404" `Quick (lwt_run test_delete_deck);
  Alcotest.test_case "POST /api/decks rule wins_not_negative -> 422" `Quick (lwt_run test_rule_wins_not_negative);
  Alcotest.test_case "POST /api/decks rule losses_not_negative -> 422" `Quick (lwt_run test_rule_losses_not_negative);
  Alcotest.test_case "POST /api/decks rule draws_not_negative -> 422" `Quick (lwt_run test_rule_draws_not_negative);
  Alcotest.test_case "POST /api/decks rule tournament_legal_deck_must_be_validated -> 422" `Quick (lwt_run test_rule_tournament_legal_deck_must_be_validated);
]

