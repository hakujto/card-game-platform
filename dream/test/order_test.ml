(* Alcotest tests for Order — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_order_id = ref 0

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
  let setup_body = Printf.sprintf "{\n    \"status\": \"not_Paid\",\n    \"total\": 0,\n    \"discount_applied\": 0,\n    \"currency\": \"test\",\n    \"payment_method\": null,\n    \"payment_reference\": null,\n    \"shipping_address\": null,\n    \"tracking_number\": null,\n    \"paid_at\": null,\n    \"player_id\": %d,\n    \"coupon_id\": null\n  }" !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/orders" setup_body in
  setup_order_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

(* Caller identity for ownership-guarded endpoints — must match the *)
(* <own_field>_id persisted on the main entity in setUp, or every  *)
(* GET/PATCH/DELETE below would 403 against its own record.        *)
let auth_headers = [("X-User-Id", string_of_int !setup_player_id)]

let test_list_order () =
  let* code = get "/api/orders" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_order () =
  let create_body = Printf.sprintf "{\n    \"status\": \"not_Paid\",\n    \"total\": 0,\n    \"discount_applied\": 0,\n    \"currency\": \"test\",\n    \"payment_method\": null,\n    \"payment_reference\": null,\n    \"shipping_address\": null,\n    \"tracking_number\": null,\n    \"paid_at\": null,\n    \"player_id\": %d,\n    \"coupon_id\": null\n  }" !(setup_player_id) in
  let* code = post ~headers:auth_headers "/api/orders" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_order () =
  let url = Printf.sprintf "/api/orders/%d" !setup_order_id in
  let* code = get ~headers:auth_headers url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_paid_requires_paid_at () =
  (* Rule: paid_requires_paid_at — body violates the condition *)
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
  (* Rule: shipped_requires_tracking — body violates the condition *)
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
  (* Rule: shipped_at_requires_shipped_status — body violates the condition *)
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
  (* Rule: total_not_negative — body violates the condition *)
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
  (* Rule: discount_not_exceed_total — body violates the condition *)
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
  Alcotest.test_case "GET /api/orders/<id> returns 200" `Quick (lwt_run test_get_order);
  Alcotest.test_case "POST /api/orders rule paid_requires_paid_at -> 422" `Quick (lwt_run test_rule_paid_requires_paid_at);
  Alcotest.test_case "POST /api/orders rule shipped_requires_tracking -> 422" `Quick (lwt_run test_rule_shipped_requires_tracking);
  Alcotest.test_case "POST /api/orders rule shipped_at_requires_shipped_status -> 422" `Quick (lwt_run test_rule_shipped_at_requires_shipped_status);
  Alcotest.test_case "POST /api/orders rule total_not_negative -> 422" `Quick (lwt_run test_rule_total_not_negative);
  Alcotest.test_case "POST /api/orders rule discount_not_exceed_total -> 422" `Quick (lwt_run test_rule_discount_not_exceed_total);
]

