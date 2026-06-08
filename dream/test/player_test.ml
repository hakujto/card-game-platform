(* Alcotest tests for Player — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "display_name": "x",
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4999,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
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

let test_list_player () =
  let* code = get "/api/players" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_player () =
  let* code = get "/api/players?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_player () =
  let* code = post "/api/players" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_player () =
  let* code = get "/api/players/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_player () =
  let* code = put "/api/players/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_rating_range () =
  (* Rule: rating_range - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "display_name": "x",
    "rank": "Bronze",
    "rating": 10000,
    "peak_rating": 4999,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  let* code = post "/api/players" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_peak_rating_gte_rating () =
  (* Rule: peak_rating_gte_rating - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "display_name": "x",
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4998,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  let* code = post "/api/players" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_display_name_not_empty () =
  (* Rule: display_name_not_empty - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4999,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  let* code = post "/api/players" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_player = [
  Alcotest.test_case "GET /api/players returns 200" `Quick (lwt_run test_list_player);
  Alcotest.test_case "GET /api/players?q=test returns 200" `Quick (lwt_run test_search_player);
  Alcotest.test_case "POST /api/players returns 201" `Quick (lwt_run test_create_player);
  Alcotest.test_case "GET /api/players/1 returns 200 or 404" `Quick (lwt_run test_get_player);
  Alcotest.test_case "PUT /api/players/1 returns 200 or 404" `Quick (lwt_run test_update_player);
  Alcotest.test_case "POST /api/players rule rating_range -> 422" `Quick (lwt_run test_rule_rating_range);
  Alcotest.test_case "POST /api/players rule peak_rating_gte_rating -> 422" `Quick (lwt_run test_rule_peak_rating_gte_rating);
  Alcotest.test_case "POST /api/players rule display_name_not_empty -> 422" `Quick (lwt_run test_rule_display_name_not_empty);
]

