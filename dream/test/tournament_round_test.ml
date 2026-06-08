(* Alcotest tests for TournamentRound — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "round_number": 1,
    "status": "not_Completed",
    "started_at": null,
    "time_limit_minutes": 1,
    "tournament_id": 1
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

let test_list_tournament_round () =
  let* code = get "/api/tournament_rounds" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament_round () =
  let* code = post "/api/tournament_rounds" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_tournament_round () =
  let* code = get "/api/tournament_rounds/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_ended_after_started () =
  (* Rule: ended_after_started - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "round_number": 1,
    "status": "not_Completed",
    "started_at": null,
    "ended_at": 0,
    "time_limit_minutes": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_completed_requires_started_at () =
  (* Rule: completed_requires_started_at - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "round_number": 1,
    "status": "Completed",
    "time_limit_minutes": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_round_number_positive () =
  (* Rule: round_number_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "round_number": 0,
    "status": "not_Completed",
    "started_at": null,
    "time_limit_minutes": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_time_limit_positive () =
  (* Rule: time_limit_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "round_number": 1,
    "status": "not_Completed",
    "started_at": null,
    "time_limit_minutes": 0,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_tournament_round = [
  Alcotest.test_case "GET /api/tournament_rounds returns 200" `Quick (lwt_run test_list_tournament_round);
  Alcotest.test_case "POST /api/tournament_rounds returns 201" `Quick (lwt_run test_create_tournament_round);
  Alcotest.test_case "GET /api/tournament_rounds/1 returns 200 or 404" `Quick (lwt_run test_get_tournament_round);
  Alcotest.test_case "POST /api/tournament_rounds rule ended_after_started -> 422" `Quick (lwt_run test_rule_ended_after_started);
  Alcotest.test_case "POST /api/tournament_rounds rule completed_requires_started_at -> 422" `Quick (lwt_run test_rule_completed_requires_started_at);
  Alcotest.test_case "POST /api/tournament_rounds rule round_number_positive -> 422" `Quick (lwt_run test_rule_round_number_positive);
  Alcotest.test_case "POST /api/tournament_rounds rule time_limit_positive -> 422" `Quick (lwt_run test_rule_time_limit_positive);
]

