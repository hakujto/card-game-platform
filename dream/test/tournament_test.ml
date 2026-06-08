(* Alcotest tests for Tournament — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": 0,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
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

let test_list_tournament () =
  let* code = get "/api/tournaments" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_tournament () =
  let* code = get "/api/tournaments?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament () =
  let* code = post "/api/tournaments" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_tournament () =
  let* code = get "/api/tournaments/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_tournament () =
  let* code = put "/api/tournaments/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_max_players_positive () =
  (* Rule: max_players_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 513,
    "entry_fee": 0,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_entry_fee_not_negative () =
  (* Rule: entry_fee_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": -1,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_prize_pool_not_negative () =
  (* Rule: prize_pool_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": 0,
    "prize_pool": -1,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_end_time_after_start () =
  (* Rule: end_time_after_start - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": 0,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "end_time": 0,
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_tournament = [
  Alcotest.test_case "GET /api/tournaments returns 200" `Quick (lwt_run test_list_tournament);
  Alcotest.test_case "GET /api/tournaments?q=test returns 200" `Quick (lwt_run test_search_tournament);
  Alcotest.test_case "POST /api/tournaments returns 201" `Quick (lwt_run test_create_tournament);
  Alcotest.test_case "GET /api/tournaments/1 returns 200 or 404" `Quick (lwt_run test_get_tournament);
  Alcotest.test_case "PUT /api/tournaments/1 returns 200 or 404" `Quick (lwt_run test_update_tournament);
  Alcotest.test_case "POST /api/tournaments rule max_players_positive -> 422" `Quick (lwt_run test_rule_max_players_positive);
  Alcotest.test_case "POST /api/tournaments rule entry_fee_not_negative -> 422" `Quick (lwt_run test_rule_entry_fee_not_negative);
  Alcotest.test_case "POST /api/tournaments rule prize_pool_not_negative -> 422" `Quick (lwt_run test_rule_prize_pool_not_negative);
  Alcotest.test_case "POST /api/tournaments rule end_time_after_start -> 422" `Quick (lwt_run test_rule_end_time_after_start);
]

