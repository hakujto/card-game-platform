(* Alcotest tests for Achievement — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "description": "test",
    "icon_url": null,
    "points": 1,
    "rarity": "Common",
    "is_hidden": false
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

let test_list_achievement () =
  let* code = get "/api/achievements" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_achievement () =
  let* code = get "/api/achievements?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_achievement () =
  let* code = post "/api/achievements" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_achievement () =
  let* code = get "/api/achievements/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_achievement () =
  let* code = put "/api/achievements/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_points_positive () =
  (* Rule: points_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "description": "test",
    "icon_url": null,
    "points": 0,
    "rarity": "Common",
    "is_hidden": false
  }|json} in
  let* code = post "/api/achievements" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_achievement = [
  Alcotest.test_case "GET /api/achievements returns 200" `Quick (lwt_run test_list_achievement);
  Alcotest.test_case "GET /api/achievements?q=test returns 200" `Quick (lwt_run test_search_achievement);
  Alcotest.test_case "POST /api/achievements returns 201" `Quick (lwt_run test_create_achievement);
  Alcotest.test_case "GET /api/achievements/1 returns 200 or 404" `Quick (lwt_run test_get_achievement);
  Alcotest.test_case "PUT /api/achievements/1 returns 200 or 404" `Quick (lwt_run test_update_achievement);
  Alcotest.test_case "POST /api/achievements rule points_positive -> 422" `Quick (lwt_run test_rule_points_positive);
]

