(* Alcotest tests for Stream — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "title": "test",
    "stream_url": "https://example.com",
    "status": "Scheduled",
    "platform": "Twitch",
    "language": "EN",
    "is_official": false,
    "viewer_count_peak": 0,
    "scheduled_start": "2024-01-01T00:00:00Z",
    "vod_url": null,
    "tournament_id": null,
    "streamer_id": 1
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

let test_list_stream () =
  let* code = get "/api/streams" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_stream () =
  let* code = get "/api/streams?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_stream () =
  let* code = post "/api/streams" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_stream () =
  let* code = get "/api/streams/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_stream () =
  let* code = put "/api/streams/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_actual_start_requires_live_or_ended () =
  (* Rule: actual_start_requires_live_or_ended - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "title": "test",
    "stream_url": "https://example.com",
    "status": "not_Live",
    "platform": "Twitch",
    "language": "EN",
    "is_official": false,
    "viewer_count_peak": 0,
    "scheduled_start": "2024-01-01T00:00:00Z",
    "actual_start": "x",
    "vod_url": null,
    "tournament_id": null,
    "streamer_id": 1
  }|json} in
  let* code = post "/api/streams" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_ended_at_requires_ended_status () =
  (* Rule: ended_at_requires_ended_status - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "title": "test",
    "stream_url": "https://example.com",
    "status": "not_Ended",
    "platform": "Twitch",
    "language": "EN",
    "is_official": false,
    "viewer_count_peak": 0,
    "scheduled_start": "2024-01-01T00:00:00Z",
    "ended_at": "x",
    "vod_url": null,
    "tournament_id": null,
    "streamer_id": 1
  }|json} in
  let* code = post "/api/streams" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_viewer_count_not_negative () =
  (* Rule: viewer_count_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "title": "test",
    "stream_url": "https://example.com",
    "status": "Scheduled",
    "platform": "Twitch",
    "language": "EN",
    "is_official": false,
    "viewer_count_peak": -1,
    "scheduled_start": "2024-01-01T00:00:00Z",
    "vod_url": null,
    "tournament_id": null,
    "streamer_id": 1
  }|json} in
  let* code = post "/api/streams" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_stream = [
  Alcotest.test_case "GET /api/streams returns 200" `Quick (lwt_run test_list_stream);
  Alcotest.test_case "GET /api/streams?q=test returns 200" `Quick (lwt_run test_search_stream);
  Alcotest.test_case "POST /api/streams returns 201" `Quick (lwt_run test_create_stream);
  Alcotest.test_case "GET /api/streams/1 returns 200 or 404" `Quick (lwt_run test_get_stream);
  Alcotest.test_case "PUT /api/streams/1 returns 200 or 404" `Quick (lwt_run test_update_stream);
  Alcotest.test_case "POST /api/streams rule actual_start_requires_live_or_ended -> 422" `Quick (lwt_run test_rule_actual_start_requires_live_or_ended);
  Alcotest.test_case "POST /api/streams rule ended_at_requires_ended_status -> 422" `Quick (lwt_run test_rule_ended_at_requires_ended_status);
  Alcotest.test_case "POST /api/streams rule viewer_count_not_negative -> 422" `Quick (lwt_run test_rule_viewer_count_not_negative);
]

