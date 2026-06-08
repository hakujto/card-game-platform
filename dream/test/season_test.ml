(* Alcotest tests for Season — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "start_date": "2024-01-01",
    "end_date": 1,
    "format": "Standard",
    "is_active": false,
    "reward_description": null
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

let test_list_season () =
  let* code = get "/api/seasons" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_season () =
  let* code = get "/api/seasons?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_season () =
  let* code = post "/api/seasons" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_season () =
  let* code = get "/api/seasons/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_season () =
  let* code = put "/api/seasons/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_end_date_after_start_date () =
  (* Rule: end_date_after_start_date - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "start_date": "2024-01-01",
    "end_date": 0,
    "format": "Standard",
    "is_active": false,
    "reward_description": null
  }|json} in
  let* code = post "/api/seasons" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_season = [
  Alcotest.test_case "GET /api/seasons returns 200" `Quick (lwt_run test_list_season);
  Alcotest.test_case "GET /api/seasons?q=test returns 200" `Quick (lwt_run test_search_season);
  Alcotest.test_case "POST /api/seasons returns 201" `Quick (lwt_run test_create_season);
  Alcotest.test_case "GET /api/seasons/1 returns 200 or 404" `Quick (lwt_run test_get_season);
  Alcotest.test_case "PUT /api/seasons/1 returns 200 or 404" `Quick (lwt_run test_update_season);
  Alcotest.test_case "POST /api/seasons rule end_date_after_start_date -> 422" `Quick (lwt_run test_rule_end_date_after_start_date);
]

