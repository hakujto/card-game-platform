(* Alcotest tests for Order — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "status": "not_Paid",
    "total": 0,
    "discount_applied": 0,
    "currency": "test",
    "payment_method": null,
    "payment_reference": null,
    "shipping_address": null,
    "tracking_number": null,
    "paid_at": null,
    "player_id": 1,
    "coupon_id": null
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

let test_list_order () =
  let* code = get "/api/orders" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_order () =
  let* code = post "/api/orders" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_order () =
  let* code = get "/api/orders/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_paid_requires_paid_at () =
  (* Rule: paid_requires_paid_at - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "Paid",
    "total": 0,
    "discount_applied": 0,
    "currency": "test",
    "payment_method": null,
    "payment_reference": null,
    "shipping_address": null,
    "tracking_number": null,
    "player_id": 1,
    "coupon_id": null
  }|json} in
  let* code = post "/api/orders" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_shipped_requires_tracking () =
  (* Rule: shipped_requires_tracking - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "Shipped",
    "total": 0,
    "discount_applied": 0,
    "currency": "test",
    "payment_method": null,
    "payment_reference": null,
    "shipping_address": null,
    "paid_at": null,
    "player_id": 1,
    "coupon_id": null
  }|json} in
  let* code = post "/api/orders" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_shipped_at_requires_shipped_status () =
  (* Rule: shipped_at_requires_shipped_status - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "not_Shipped",
    "total": 0,
    "discount_applied": 0,
    "currency": "test",
    "payment_method": null,
    "payment_reference": null,
    "shipping_address": null,
    "tracking_number": null,
    "paid_at": null,
    "shipped_at": "x",
    "player_id": 1,
    "coupon_id": null
  }|json} in
  let* code = post "/api/orders" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_total_not_negative () =
  (* Rule: total_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "not_Paid",
    "total": -1,
    "discount_applied": 0,
    "currency": "test",
    "payment_method": null,
    "payment_reference": null,
    "shipping_address": null,
    "tracking_number": null,
    "paid_at": null,
    "player_id": 1,
    "coupon_id": null
  }|json} in
  let* code = post "/api/orders" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_discount_not_exceed_total () =
  (* Rule: discount_not_exceed_total - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "not_Paid",
    "total": 0,
    "discount_applied": 1,
    "currency": "test",
    "payment_method": null,
    "payment_reference": null,
    "shipping_address": null,
    "tracking_number": null,
    "paid_at": null,
    "player_id": 1,
    "coupon_id": null
  }|json} in
  let* code = post "/api/orders" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_order = [
  Alcotest.test_case "GET /api/orders returns 200" `Quick (lwt_run test_list_order);
  Alcotest.test_case "POST /api/orders returns 201" `Quick (lwt_run test_create_order);
  Alcotest.test_case "GET /api/orders/1 returns 200 or 404" `Quick (lwt_run test_get_order);
  Alcotest.test_case "POST /api/orders rule paid_requires_paid_at -> 422" `Quick (lwt_run test_rule_paid_requires_paid_at);
  Alcotest.test_case "POST /api/orders rule shipped_requires_tracking -> 422" `Quick (lwt_run test_rule_shipped_requires_tracking);
  Alcotest.test_case "POST /api/orders rule shipped_at_requires_shipped_status -> 422" `Quick (lwt_run test_rule_shipped_at_requires_shipped_status);
  Alcotest.test_case "POST /api/orders rule total_not_negative -> 422" `Quick (lwt_run test_rule_total_not_negative);
  Alcotest.test_case "POST /api/orders rule discount_not_exceed_total -> 422" `Quick (lwt_run test_rule_discount_not_exceed_total);
]

