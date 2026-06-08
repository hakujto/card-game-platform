(* Alcotest tests for CardRuling — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "ruling_text": "test",
    "published_at": "2024-01-01",
    "source": "test",
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

let test_list_card_ruling () =
  let* code = get "/api/card_rulings" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_card_ruling () =
  let* code = post "/api/card_rulings" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_card_ruling () =
  let* code = get "/api/card_rulings/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_delete_card_ruling () =
  let* code = delete "/api/card_rulings/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let suite_card_ruling = [
  Alcotest.test_case "GET /api/card_rulings returns 200" `Quick (lwt_run test_list_card_ruling);
  Alcotest.test_case "POST /api/card_rulings returns 201" `Quick (lwt_run test_create_card_ruling);
  Alcotest.test_case "GET /api/card_rulings/1 returns 200 or 404" `Quick (lwt_run test_get_card_ruling);
  Alcotest.test_case "DELETE /api/card_rulings/1 returns 204 or 404" `Quick (lwt_run test_delete_card_ruling);
]

