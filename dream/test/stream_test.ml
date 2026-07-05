(* Alcotest tests for Stream — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_stream_id = ref 0

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
  let setup_body = Printf.sprintf "{\n    \"title\": \"test\",\n    \"stream_url\": \"https://example.com\",\n    \"status\": \"Scheduled\",\n    \"platform\": \"Twitch\",\n    \"language\": \"EN\",\n    \"is_official\": false,\n    \"viewer_count_peak\": 0,\n    \"scheduled_start\": \"2024-01-01T00:00:00Z\",\n    \"vod_url\": null,\n    \"tournament_id\": null,\n    \"streamer_id\": %d\n  }" !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/streams" setup_body in
  setup_stream_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_stream () =
  let* code = get "/api/streams" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_stream () =
  let* code = get "/api/streams?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_stream () =
  let create_body = Printf.sprintf "{\n    \"title\": \"test\",\n    \"stream_url\": \"https://example.com\",\n    \"status\": \"Scheduled\",\n    \"platform\": \"Twitch\",\n    \"language\": \"EN\",\n    \"is_official\": false,\n    \"viewer_count_peak\": 0,\n    \"scheduled_start\": \"2024-01-01T00:00:00Z\",\n    \"vod_url\": null,\n    \"tournament_id\": null,\n    \"streamer_id\": %d\n  }" !(setup_player_id) in
  let* code = post "/api/streams" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_stream () =
  let url = Printf.sprintf "/api/streams/%d" !setup_stream_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_stream () =
  let url = Printf.sprintf "/api/streams/%d" !setup_stream_id in
  let update_body = Printf.sprintf "{\n    \"title\": \"test\",\n    \"stream_url\": \"https://example.com\",\n    \"status\": \"Scheduled\",\n    \"platform\": \"Twitch\",\n    \"language\": \"EN\",\n    \"is_official\": false,\n    \"viewer_count_peak\": 0,\n    \"scheduled_start\": \"2024-01-01T00:00:00Z\",\n    \"vod_url\": null,\n    \"tournament_id\": null,\n    \"streamer_id\": %d\n  }" !(setup_player_id) in
  let* code = put url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_rule_actual_start_requires_live_or_ended () =
  (* Rule: actual_start_requires_live_or_ended — body violates the condition *)
  let body = {json|{
    "title": "test",
    "stream_url": "https://example.com",
    "status": "Scheduled",
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
  (* Rule: ended_at_requires_ended_status — body violates the condition *)
  let body = {json|{
    "title": "test",
    "stream_url": "https://example.com",
    "status": "Scheduled",
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
  (* Rule: viewer_count_not_negative — body violates the condition *)
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
  Alcotest.test_case "GET /api/streams/<id> returns 200" `Quick (lwt_run test_get_stream);
  Alcotest.test_case "PUT /api/streams/<id> returns 200" `Quick (lwt_run test_update_stream);
  Alcotest.test_case "POST /api/streams rule actual_start_requires_live_or_ended -> 422" `Quick (lwt_run test_rule_actual_start_requires_live_or_ended);
  Alcotest.test_case "POST /api/streams rule ended_at_requires_ended_status -> 422" `Quick (lwt_run test_rule_ended_at_requires_ended_status);
  Alcotest.test_case "POST /api/streams rule viewer_count_not_negative -> 422" `Quick (lwt_run test_rule_viewer_count_not_negative);
]

