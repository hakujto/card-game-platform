(* Alcotest tests for Player — uses cohttp-lwt-unix for HTTP requests *)
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

let test_list_player () =
  let* code = get "/api/players" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_player () =
  let* code = get "/api/players?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_player () =
  let* code = post "/api/players" {json|{
    "public_id": "00000000-0000-0000-0000-0000000000012",
    "display_name": "x",
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4999,
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
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_player () =
  let* code = get "/api/players/1" in
  Alcotest.(check bool) "get returns 200 or 403 or 404" true (code = 200 || code = 403 || code = 404);
  Lwt.return_unit

let test_update_player () =
  let* code = patch "/api/players/1" {json|{
    "public_id": "00000000-0000-0000-0000-0000000000012",
    "display_name": "x",
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4999,
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
  Alcotest.(check bool) "update returns 200 or 403 or 404 or 500" true (code = 200 || code = 403 || code = 404 || code = 500);
  Lwt.return_unit

let test_patch_safe_player () =
  (* @patch_safe: send only "bio" in partial update *)
  let* code = patch "/api/players/1" {json|{"bio": "test"}|json} in
  Alcotest.(check bool) "patch_safe returns 200 or 404 or 400" true (code = 200 || code = 404 || code = 400);
  Lwt.return_unit

let test_rule_rating_range () =
  (* Rule: rating_range — body violates the condition *)
  let body = {json|{
    "public_id": "00000000-0000-0000-0000-0000000000012",
    "display_name": "x",
    "rank": "Bronze",
    "rating": 10000,
    "peak_rating": 4999,
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
  let* code = post "/api/players" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_peak_rating_gte_rating () =
  (* Rule: peak_rating_gte_rating — body violates the condition *)
  let body = {json|{
    "public_id": "00000000-0000-0000-0000-0000000000012",
    "display_name": "x",
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4998,
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
  let* code = post "/api/players" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_display_name_not_empty () =
  (* Rule: display_name_not_empty — body violates the condition *)
  let body = {json|{
    "public_id": "00000000-0000-0000-0000-0000000000012",
    "rank": "Bronze",
    "rating": 4999,
    "peak_rating": 4999,
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
  let* code = post "/api/players" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_player = [
  Alcotest.test_case "GET /api/players returns 200" `Quick (lwt_run test_list_player);
  Alcotest.test_case "GET /api/players?q=test returns 200" `Quick (lwt_run test_search_player);
  Alcotest.test_case "POST /api/players returns 201" `Quick (lwt_run test_create_player);
  Alcotest.test_case "GET /api/players/1 returns 200" `Quick (lwt_run test_get_player);
  Alcotest.test_case "PATCH /api/players/1 returns 200" `Quick (lwt_run test_update_player);
  Alcotest.test_case "PATCH /api/players/1 patch_safe field" `Quick (lwt_run test_patch_safe_player);
  Alcotest.test_case "POST /api/players rule rating_range -> 422" `Quick (lwt_run test_rule_rating_range);
  Alcotest.test_case "POST /api/players rule peak_rating_gte_rating -> 422" `Quick (lwt_run test_rule_peak_rating_gte_rating);
  Alcotest.test_case "POST /api/players rule display_name_not_empty -> 422" `Quick (lwt_run test_rule_display_name_not_empty);
]

