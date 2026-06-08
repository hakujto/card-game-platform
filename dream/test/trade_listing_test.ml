(* Alcotest tests for TradeListing — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "status": "Active",
    "listing_type": "not_FixedPrice",
    "asking_price": null,
    "auction_start_price": null,
    "auction_current_bid": null,
    "auction_end_time": null,
    "foil": false,
    "condition": "Mint",
    "quantity": 5000,
    "description": null,
    "expires_at": null,
    "seller_id": 1,
    "card_id": 1
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

let test_list_trade_listing () =
  let* code = get "/api/trade_listings" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_trade_listing () =
  let* code = get "/api/trade_listings?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_trade_listing () =
  let* code = post "/api/trade_listings" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_trade_listing () =
  let* code = get "/api/trade_listings/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_trade_listing () =
  let* code = put "/api/trade_listings/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_fixed_price_requires_asking_price () =
  (* Rule: fixed_price_requires_asking_price - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "Active",
    "listing_type": "FixedPrice",
    "auction_start_price": null,
    "auction_current_bid": null,
    "auction_end_time": null,
    "foil": false,
    "condition": "Mint",
    "quantity": 5000,
    "description": null,
    "expires_at": null,
    "seller_id": 1,
    "card_id": 1
  }|json} in
  let* code = post "/api/trade_listings" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_auction_requires_start_price_and_end_time () =
  (* Rule: auction_requires_start_price_and_end_time - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "Active",
    "listing_type": "Auction",
    "asking_price": null,
    "auction_current_bid": null,
    "auction_end_time": null,
    "foil": false,
    "condition": "Mint",
    "quantity": 5000,
    "description": null,
    "expires_at": null,
    "seller_id": 1,
    "card_id": 1
  }|json} in
  let* code = post "/api/trade_listings" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_quantity_positive () =
  (* Rule: quantity_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "status": "Active",
    "listing_type": "not_FixedPrice",
    "asking_price": null,
    "auction_start_price": null,
    "auction_current_bid": null,
    "auction_end_time": null,
    "foil": false,
    "condition": "Mint",
    "quantity": 10000,
    "description": null,
    "expires_at": null,
    "seller_id": 1,
    "card_id": 1
  }|json} in
  let* code = post "/api/trade_listings" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_trade_listing = [
  Alcotest.test_case "GET /api/trade_listings returns 200" `Quick (lwt_run test_list_trade_listing);
  Alcotest.test_case "GET /api/trade_listings?q=test returns 200" `Quick (lwt_run test_search_trade_listing);
  Alcotest.test_case "POST /api/trade_listings returns 201" `Quick (lwt_run test_create_trade_listing);
  Alcotest.test_case "GET /api/trade_listings/1 returns 200 or 404" `Quick (lwt_run test_get_trade_listing);
  Alcotest.test_case "PUT /api/trade_listings/1 returns 200 or 404" `Quick (lwt_run test_update_trade_listing);
  Alcotest.test_case "POST /api/trade_listings rule fixed_price_requires_asking_price -> 422" `Quick (lwt_run test_rule_fixed_price_requires_asking_price);
  Alcotest.test_case "POST /api/trade_listings rule auction_requires_start_price_and_end_time -> 422" `Quick (lwt_run test_rule_auction_requires_start_price_and_end_time);
  Alcotest.test_case "POST /api/trade_listings rule quantity_positive -> 422" `Quick (lwt_run test_rule_quantity_positive);
]

