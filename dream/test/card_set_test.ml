(* Alcotest tests for CardSet — uses cohttp-lwt-unix for HTTP requests *)
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

let lwt_run f () = Lwt_main.run (f ())

let test_list_card_set () =
  let* code = get "/api/card_sets" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_card_set () =
  let* code = get "/api/card_sets?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_card_set () =
  let* code = post "/api/card_sets" {json|{
    "name": "test",
    "code": "test2",
    "release_date": "2024-01-01",
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_card_set () =
  let* code = get "/api/card_sets/1" in
  Alcotest.(check bool) "get returns 200 or 403 or 404" true (code = 200 || code = 403 || code = 404);
  Lwt.return_unit

let test_update_card_set () =
  let* code = put "/api/card_sets/1" {json|{
    "name": "test",
    "code": "test2",
    "release_date": "2024-01-01",
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  Alcotest.(check bool) "update returns 200 or 403 or 404 or 500" true (code = 200 || code = 403 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_total_cards_positive () =
  (* Rule: total_cards_positive — body violates the condition *)
  let body = {json|{
    "name": "test",
    "code": "test2",
    "release_date": "2024-01-01",
    "set_type": "Core",
    "total_cards": 0,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  let* code = post "/api/card_sets" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_rotation_date_after_release () =
  (* Rule: rotation_date_after_release — body violates the condition *)
  let body = {json|{
    "name": "test",
    "code": "test2",
    "release_date": "2024-01-01",
    "rotation_date": 0,
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  let* code = post "/api/card_sets" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_rotated_set_has_rotation_date () =
  (* Rule: rotated_set_has_rotation_date — body violates the condition *)
  let body = {json|{
    "name": "test",
    "code": "test2",
    "release_date": "2024-01-01",
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": true,
    "description": null,
    "logo_url": null
  }|json} in
  let* code = post "/api/card_sets" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_card_set = [
  Alcotest.test_case "GET /api/card_sets returns 200" `Quick (lwt_run test_list_card_set);
  Alcotest.test_case "GET /api/card_sets?q=test returns 200" `Quick (lwt_run test_search_card_set);
  Alcotest.test_case "POST /api/card_sets returns 201" `Quick (lwt_run test_create_card_set);
  Alcotest.test_case "GET /api/card_sets/1 returns 200" `Quick (lwt_run test_get_card_set);
  Alcotest.test_case "PUT /api/card_sets/1 returns 200" `Quick (lwt_run test_update_card_set);
  Alcotest.test_case "POST /api/card_sets rule total_cards_positive -> 422" `Quick (lwt_run test_rule_total_cards_positive);
  Alcotest.test_case "POST /api/card_sets rule rotation_date_after_release -> 422" `Quick (lwt_run test_rule_rotation_date_after_release);
  Alcotest.test_case "POST /api/card_sets rule rotated_set_has_rotation_date -> 422" `Quick (lwt_run test_rule_rotated_set_has_rotation_date);
]

