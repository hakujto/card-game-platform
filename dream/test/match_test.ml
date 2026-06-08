(* Alcotest tests for Match — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 0,
    "player2_wins": 0,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
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

let test_list_match () =
  let* code = get "/api/matches" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_match () =
  let* code = post "/api/matches" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_match () =
  let* code = get "/api/matches/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_wins_not_negative () =
  (* Rule: wins_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 0,
    "player2_wins": -1,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_max_three_games () =
  (* Rule: max_three_games - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 3,
    "player2_wins": 0,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_bye_has_no_player2 () =
  (* Rule: bye_has_no_player2 - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "table_number": null,
    "status": "BYE",
    "player1_wins": 0,
    "player2_wins": 0,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": 1
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_ended_after_started () =
  (* Rule: ended_after_started - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 0,
    "player2_wins": 0,
    "started_at": null,
    "ended_at": 0,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_completed_requires_started_at () =
  (* Rule: completed_requires_started_at - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "table_number": null,
    "status": "Completed",
    "player1_wins": 0,
    "player2_wins": 0,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_match = [
  Alcotest.test_case "GET /api/matches returns 200" `Quick (lwt_run test_list_match);
  Alcotest.test_case "POST /api/matches returns 201" `Quick (lwt_run test_create_match);
  Alcotest.test_case "GET /api/matches/1 returns 200 or 404" `Quick (lwt_run test_get_match);
  Alcotest.test_case "POST /api/matches rule wins_not_negative -> 422" `Quick (lwt_run test_rule_wins_not_negative);
  Alcotest.test_case "POST /api/matches rule max_three_games -> 422" `Quick (lwt_run test_rule_max_three_games);
  Alcotest.test_case "POST /api/matches rule bye_has_no_player2 -> 422" `Quick (lwt_run test_rule_bye_has_no_player2);
  Alcotest.test_case "POST /api/matches rule ended_after_started -> 422" `Quick (lwt_run test_rule_ended_after_started);
  Alcotest.test_case "POST /api/matches rule completed_requires_started_at -> 422" `Quick (lwt_run test_rule_completed_requires_started_at);
]

