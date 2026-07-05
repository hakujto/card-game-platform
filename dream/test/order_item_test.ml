(* Alcotest tests for OrderItem — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_product_id = ref 0
let setup_order_item_id = ref 0

let do_setup () =
  let* (_, dep_id_player) = post_for_id "/api/players" {json|{
    "public_id": "00000000-0000-0000-0000-000000000001",
    "display_name": "test",
    "rank": "Bronze",
    "rating": 1,
    "peak_rating": 1,
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
  setup_player_id := dep_id_player;
  let dep_body_order = Printf.sprintf "{\n    \"status\": \"Pending\",\n    \"total\": 1.0,\n    \"discount_applied\": 1.0,\n    \"currency\": \"test\",\n    \"payment_method\": null,\n    \"payment_reference\": null,\n    \"shipping_address\": null,\n    \"tracking_number\": null,\n    \"paid_at\": null,\n    \"shipped_at\": null,\n    \"player_id\": %d,\n    \"coupon_id\": null\n  }" !(setup_player_id) in
  let* (_, dep_id_order) = post_for_id "/api/orders" dep_body_order in
  setup_order_id := dep_id_order;
  let* (_, dep_id_product) = post_for_id "/api/products" {json|{
    "name": "test",
    "product_type": "SingleCard",
    "price": 1.0,
    "stock": 1,
    "active": false,
    "discount_percent": 1,
    "description": null,
    "image_url": null,
    "featured": false,
    "card_id": null,
    "card_set_id": null
  }|json} in
  setup_product_id := dep_id_product;
  let setup_body = Printf.sprintf "{\n    \"quantity\": 1,\n    \"price_at_purchase\": 0,\n    \"foil\": false,\n    \"order_id\": %d,\n    \"product_id\": %d\n  }" !(setup_order_id) !(setup_product_id) in
  let* (_, main_id) = post_for_id "/api/order_items" setup_body in
  setup_order_item_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_order_item () =
  let* code = get "/api/order_items" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_order_item () =
  let create_body = Printf.sprintf "{\n    \"quantity\": 1,\n    \"price_at_purchase\": 0,\n    \"foil\": false,\n    \"order_id\": %d,\n    \"product_id\": %d\n  }" !(setup_order_id) !(setup_product_id) in
  let* code = post "/api/order_items" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_order_item () =
  let url = Printf.sprintf "/api/order_items/%d" !setup_order_item_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_delete_order_item () =
  let url = Printf.sprintf "/api/order_items/%d" !setup_order_item_id in
  let* code = delete url in
  Alcotest.(check int) "delete returns 204" 204 code;
  Lwt.return_unit

let test_rule_quantity_positive () =
  (* Rule: quantity_positive — body violates the condition *)
  let body = {json|{
    "quantity": 0,
    "price_at_purchase": 0,
    "foil": false,
    "order_id": 1,
    "product_id": 1
  }|json} in
  let* code = post "/api/order_items" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_price_not_negative () =
  (* Rule: price_not_negative — body violates the condition *)
  let body = {json|{
    "quantity": 1,
    "price_at_purchase": -1,
    "foil": false,
    "order_id": 1,
    "product_id": 1
  }|json} in
  let* code = post "/api/order_items" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_order_item = [
  Alcotest.test_case "GET /api/order_items returns 200" `Quick (lwt_run test_list_order_item);
  Alcotest.test_case "POST /api/order_items returns 201" `Quick (lwt_run test_create_order_item);
  Alcotest.test_case "GET /api/order_items/<id> returns 200" `Quick (lwt_run test_get_order_item);
  Alcotest.test_case "DELETE /api/order_items/<id> returns 204" `Quick (lwt_run test_delete_order_item);
  Alcotest.test_case "POST /api/order_items rule quantity_positive -> 422" `Quick (lwt_run test_rule_quantity_positive);
  Alcotest.test_case "POST /api/order_items rule price_not_negative -> 422" `Quick (lwt_run test_rule_price_not_negative);
]

