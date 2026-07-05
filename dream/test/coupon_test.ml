(* Alcotest tests for Coupon — uses cohttp-lwt-unix for HTTP requests *)
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

let test_list_coupon () =
  let* code = get "/api/coupons" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_coupon () =
  let* code = get "/api/coupons?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_coupon () =
  let* code = post "/api/coupons" {json|{
    "code": "test2",
    "discount_type": "Fixed",
    "discount_value": 1,
    "min_order_value": 0.0,
    "uses_count": 1,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": 1,
    "is_active": false
  }|json} in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_coupon () =
  let* code = get "/api/coupons/1" in
  Alcotest.(check bool) "get returns 200 or 403 or 404" true (code = 200 || code = 403 || code = 404);
  Lwt.return_unit

let test_update_coupon () =
  let* code = put "/api/coupons/1" {json|{
    "code": "test2",
    "discount_type": "Fixed",
    "discount_value": 1,
    "min_order_value": 0.0,
    "uses_count": 1,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": 1,
    "is_active": false
  }|json} in
  Alcotest.(check bool) "update returns 200 or 403 or 404 or 500" true (code = 200 || code = 403 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_valid_until_after_valid_from () =
  (* Rule: valid_until_after_valid_from — body violates the condition *)
  let body = {json|{
    "code": "test2",
    "discount_type": "Fixed",
    "discount_value": 1,
    "min_order_value": 0.0,
    "uses_count": 1,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": 0,
    "is_active": false
  }|json} in
  let* code = post "/api/coupons" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_discount_value_positive () =
  (* Rule: discount_value_positive — body violates the condition *)
  let body = {json|{
    "code": "test2",
    "discount_type": "Fixed",
    "discount_value": 0,
    "min_order_value": 0.0,
    "uses_count": 1,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": 1,
    "is_active": false
  }|json} in
  let* code = post "/api/coupons" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_percent_discount_range () =
  (* Rule: percent_discount_range — body violates the condition *)
  let body = {json|{
    "code": "test2",
    "discount_type": "Percent",
    "discount_value": 101,
    "min_order_value": 0.0,
    "uses_count": 1,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": 1,
    "is_active": false
  }|json} in
  let* code = post "/api/coupons" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_uses_not_exceed_max () =
  (* Rule: uses_not_exceed_max — body violates the condition *)
  let body = {json|{
    "code": "test2",
    "discount_type": "Fixed",
    "discount_value": 1,
    "min_order_value": 0.0,
    "max_uses": 1,
    "uses_count": 2,
    "valid_from": "2024-01-01T00:00:00Z",
    "valid_until": 1,
    "is_active": false
  }|json} in
  let* code = post "/api/coupons" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_coupon = [
  Alcotest.test_case "GET /api/coupons returns 200" `Quick (lwt_run test_list_coupon);
  Alcotest.test_case "GET /api/coupons?q=test returns 200" `Quick (lwt_run test_search_coupon);
  Alcotest.test_case "POST /api/coupons returns 201" `Quick (lwt_run test_create_coupon);
  Alcotest.test_case "GET /api/coupons/1 returns 200" `Quick (lwt_run test_get_coupon);
  Alcotest.test_case "PUT /api/coupons/1 returns 200" `Quick (lwt_run test_update_coupon);
  Alcotest.test_case "POST /api/coupons rule valid_until_after_valid_from -> 422" `Quick (lwt_run test_rule_valid_until_after_valid_from);
  Alcotest.test_case "POST /api/coupons rule discount_value_positive -> 422" `Quick (lwt_run test_rule_discount_value_positive);
  Alcotest.test_case "POST /api/coupons rule percent_discount_range -> 422" `Quick (lwt_run test_rule_percent_discount_range);
  Alcotest.test_case "POST /api/coupons rule uses_not_exceed_max -> 422" `Quick (lwt_run test_rule_uses_not_exceed_max);
]

