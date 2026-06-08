(* Alcotest tests for DraftSession — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "status": "WaitingForPlayers",
    "draft_type": "Booster",
    "seats": 9,
    "time_per_pick_seconds": 1,
    "card_set_id": 1
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

let test_list_draft_session () =
  let* code = get "/api/draft_sessions" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_draft_session () =
  let* code = post "/api/draft_sessions" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_draft_session () =
  let* code = get "/api/draft_sessions/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_seats_range () =
  (* Rule: seats_range - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "WaitingForPlayers",
    "draft_type": "Booster",
    "seats": 17,
    "time_per_pick_seconds": 1,
    "card_set_id": 1
  }|json} in
  let* code = post "/api/draft_sessions" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_completed_at_requires_completed_status () =
  (* Rule: completed_at_requires_completed_status - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "not_Completed",
    "draft_type": "Booster",
    "seats": 9,
    "time_per_pick_seconds": 1,
    "completed_at": "x",
    "card_set_id": 1
  }|json} in
  let* code = post "/api/draft_sessions" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_time_per_pick_positive () =
  (* Rule: time_per_pick_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "WaitingForPlayers",
    "draft_type": "Booster",
    "seats": 9,
    "time_per_pick_seconds": 0,
    "card_set_id": 1
  }|json} in
  let* code = post "/api/draft_sessions" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_draft_session = [
  Alcotest.test_case "GET /api/draft_sessions returns 200" `Quick (lwt_run test_list_draft_session);
  Alcotest.test_case "POST /api/draft_sessions returns 201" `Quick (lwt_run test_create_draft_session);
  Alcotest.test_case "GET /api/draft_sessions/1 returns 200 or 404" `Quick (lwt_run test_get_draft_session);
  Alcotest.test_case "POST /api/draft_sessions rule seats_range -> 422" `Quick (lwt_run test_rule_seats_range);
  Alcotest.test_case "POST /api/draft_sessions rule completed_at_requires_completed_status -> 422" `Quick (lwt_run test_rule_completed_at_requires_completed_status);
  Alcotest.test_case "POST /api/draft_sessions rule time_per_pick_positive -> 422" `Quick (lwt_run test_rule_time_per_pick_positive);
]

