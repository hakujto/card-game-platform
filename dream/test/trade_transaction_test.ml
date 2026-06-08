(* Alcotest tests for TradeTransaction — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "final_price": 2,
    "platform_fee": 1,
    "status": "not_Completed",
    "completed_at": null,
    "listing_id": 1,
    "buyer_id": 1,
    "seller_id": 1
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

let test_list_trade_transaction () =
  let* code = get "/api/trade_transactions" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_get_trade_transaction () =
  let* code = get "/api/trade_transactions/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let suite_trade_transaction = [
  Alcotest.test_case "GET /api/trade_transactions returns 200" `Quick (lwt_run test_list_trade_transaction);
  Alcotest.test_case "GET /api/trade_transactions/1 returns 200 or 404" `Quick (lwt_run test_get_trade_transaction);
]

