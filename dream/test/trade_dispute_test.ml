(* Alcotest tests for TradeDispute — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_trade_dispute_id = ref 0

let do_setup () =
  let* (_, dep_id_player) = post_for_id "/api/players" {json|{
    "display_name": "test",
    "rank": "Bronze",
    "rating": 1,
    "peak_rating": 1,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  setup_player_id := dep_id_player;
  let setup_body = Printf.sprintf "{\n    \"status\": \"Open\",\n    \"reason\": \"ItemNotReceived\",\n    \"description\": \"test\",\n    \"resolution\": null,\n    \"opened_at\": \"2024-01-01T00:00:00Z\",\n    \"transaction_id\": 1,\n    \"opened_by_id\": %d,\n    \"resolved_by_id\": null\n  }" !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/trade_disputes" setup_body in
  setup_trade_dispute_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_trade_dispute () =
  let* code = get "/api/trade_disputes" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_get_trade_dispute () =
  let url = Printf.sprintf "/api/trade_disputes/%d" !setup_trade_dispute_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_resolved_at_requires_terminal_status () =
  (* Rule: resolved_at_requires_terminal_status — body violates the condition *)
  let body = {json|{
    "status": "not_Resolved",
    "reason": "ItemNotReceived",
    "description": "test",
    "resolution": null,
    "opened_at": "2024-01-01T00:00:00Z",
    "resolved_at": "x",
    "transaction_id": 1,
    "opened_by_id": 1,
    "resolved_by_id": null
  }|json} in
  let* code = post "/api/trade_disputes" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_trade_dispute = [
  Alcotest.test_case "GET /api/trade_disputes returns 200" `Quick (lwt_run test_list_trade_dispute);
  Alcotest.test_case "GET /api/trade_disputes/<id> returns 200" `Quick (lwt_run test_get_trade_dispute);
  Alcotest.test_case "POST /api/trade_disputes rule resolved_at_requires_terminal_status -> 422" `Quick (lwt_run test_rule_resolved_at_requires_terminal_status);
]

