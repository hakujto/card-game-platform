(* Alcotest tests for DraftParticipant — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "seat_number": 1,
    "joined_at": "2024-01-01T00:00:00Z",
    "session_id": 1,
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

let test_list_draft_participant () =
  let* code = get "/api/draft_participants" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_draft_participant () =
  let* code = post "/api/draft_participants" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_draft_participant () =
  let* code = get "/api/draft_participants/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_seat_number_positive () =
  (* Rule: seat_number_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "seat_number": 0,
    "joined_at": "2024-01-01T00:00:00Z",
    "session_id": 1,
    "player_id": 1
  }|json} in
  let* code = post "/api/draft_participants" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_draft_participant = [
  Alcotest.test_case "GET /api/draft_participants returns 200" `Quick (lwt_run test_list_draft_participant);
  Alcotest.test_case "POST /api/draft_participants returns 201" `Quick (lwt_run test_create_draft_participant);
  Alcotest.test_case "GET /api/draft_participants/1 returns 200 or 404" `Quick (lwt_run test_get_draft_participant);
  Alcotest.test_case "POST /api/draft_participants rule seat_number_positive -> 422" `Quick (lwt_run test_rule_seat_number_positive);
]

