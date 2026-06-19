(* Alcotest tests for DraftSession — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_card_set_id = ref 0
let setup_draft_session_id = ref 0

let do_setup () =
  let* (_, dep_id_card_set) = post_for_id "/api/card_sets" {json|{
    "name": "test",
    "code": "test",
    "release_date": "2024-01-01",
    "rotation_date": null,
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  setup_card_set_id := dep_id_card_set;
  let setup_body = Printf.sprintf "{\n    \"status\": \"WaitingForPlayers\",\n    \"draft_type\": \"Booster\",\n    \"seats\": 9,\n    \"time_per_pick_seconds\": 1,\n    \"card_set_id\": %d\n  }" !(setup_card_set_id) in
  let* (_, main_id) = post_for_id "/api/draft_sessions" setup_body in
  setup_draft_session_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_draft_session () =
  let* code = get "/api/draft_sessions" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_draft_session () =
  let create_body = Printf.sprintf "{\n    \"status\": \"WaitingForPlayers\",\n    \"draft_type\": \"Booster\",\n    \"seats\": 9,\n    \"time_per_pick_seconds\": 1,\n    \"card_set_id\": %d\n  }" !(setup_card_set_id) in
  let* code = post "/api/draft_sessions" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_draft_session () =
  let url = Printf.sprintf "/api/draft_sessions/%d" !setup_draft_session_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_seats_range () =
  (* Rule: seats_range — body violates the condition *)
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
  (* Rule: completed_at_requires_completed_status — body violates the condition *)
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
  (* Rule: time_per_pick_positive — body violates the condition *)
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
  Alcotest.test_case "GET /api/draft_sessions/<id> returns 200" `Quick (lwt_run test_get_draft_session);
  Alcotest.test_case "POST /api/draft_sessions rule seats_range -> 422" `Quick (lwt_run test_rule_seats_range);
  Alcotest.test_case "POST /api/draft_sessions rule completed_at_requires_completed_status -> 422" `Quick (lwt_run test_rule_completed_at_requires_completed_status);
  Alcotest.test_case "POST /api/draft_sessions rule time_per_pick_positive -> 422" `Quick (lwt_run test_rule_time_per_pick_positive);
]

