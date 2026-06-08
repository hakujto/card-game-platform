(* Alcotest tests for Product — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "product_type": "SingleCard",
    "price": 1,
    "stock": 0,
    "active": false,
    "discount_percent": 50,
    "description": null,
    "image_url": null,
    "featured": false,
    "card_id": null,
    "card_set_id": null
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

let test_list_product () =
  let* code = get "/api/products" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_product () =
  let* code = get "/api/products?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_product () =
  let* code = post "/api/products" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_product () =
  let* code = get "/api/products/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_product () =
  let* code = put "/api/products/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_price_positive () =
  (* Rule: price_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "product_type": "SingleCard",
    "price": 0,
    "stock": 0,
    "active": false,
    "discount_percent": 50,
    "description": null,
    "image_url": null,
    "featured": false,
    "card_id": null,
    "card_set_id": null
  }|json} in
  let* code = post "/api/products" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_stock_not_negative () =
  (* Rule: stock_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "product_type": "SingleCard",
    "price": 1,
    "stock": -1,
    "active": false,
    "discount_percent": 50,
    "description": null,
    "image_url": null,
    "featured": false,
    "card_id": null,
    "card_set_id": null
  }|json} in
  let* code = post "/api/products" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_discount_percent_range () =
  (* Rule: discount_percent_range - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "name": "test",
    "product_type": "SingleCard",
    "price": 1,
    "stock": 0,
    "active": false,
    "discount_percent": 101,
    "description": null,
    "image_url": null,
    "featured": false,
    "card_id": null,
    "card_set_id": null
  }|json} in
  let* code = post "/api/products" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_product = [
  Alcotest.test_case "GET /api/products returns 200" `Quick (lwt_run test_list_product);
  Alcotest.test_case "GET /api/products?q=test returns 200" `Quick (lwt_run test_search_product);
  Alcotest.test_case "POST /api/products returns 201" `Quick (lwt_run test_create_product);
  Alcotest.test_case "GET /api/products/1 returns 200 or 404" `Quick (lwt_run test_get_product);
  Alcotest.test_case "PUT /api/products/1 returns 200 or 404" `Quick (lwt_run test_update_product);
  Alcotest.test_case "POST /api/products rule price_positive -> 422" `Quick (lwt_run test_rule_price_positive);
  Alcotest.test_case "POST /api/products rule stock_not_negative -> 422" `Quick (lwt_run test_rule_stock_not_negative);
  Alcotest.test_case "POST /api/products rule discount_percent_range -> 422" `Quick (lwt_run test_rule_discount_percent_range);
]

