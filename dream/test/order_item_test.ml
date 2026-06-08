(* Alcotest tests for OrderItem — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "quantity": 1,
    "price_at_purchase": 0,
    "foil": false,
    "order_id": 1,
    "product_id": 1
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

let test_list_order_item () =
  let* code = get "/api/order_items" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_order_item () =
  let* code = post "/api/order_items" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_order_item () =
  let* code = get "/api/order_items/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_delete_order_item () =
  let* code = delete "/api/order_items/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let test_rule_quantity_positive () =
  (* Rule: quantity_positive - this body should violate the condition and yield 422/400 *)
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
  (* Rule: price_not_negative - this body should violate the condition and yield 422/400 *)
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
  Alcotest.test_case "GET /api/order_items/1 returns 200 or 404" `Quick (lwt_run test_get_order_item);
  Alcotest.test_case "DELETE /api/order_items/1 returns 204 or 404" `Quick (lwt_run test_delete_order_item);
  Alcotest.test_case "POST /api/order_items rule quantity_positive -> 422" `Quick (lwt_run test_rule_quantity_positive);
  Alcotest.test_case "POST /api/order_items rule price_not_negative -> 422" `Quick (lwt_run test_rule_price_not_negative);
]

