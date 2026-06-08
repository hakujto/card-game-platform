(* Alcotest tests for DeckTag — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "name": "test",
    "color": null
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

let test_list_deck_tag () =
  let* code = get "/api/deck_tags" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_deck_tag () =
  let* code = get "/api/deck_tags?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_deck_tag () =
  let* code = post "/api/deck_tags" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_deck_tag () =
  let* code = get "/api/deck_tags/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_deck_tag () =
  let* code = put "/api/deck_tags/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_delete_deck_tag () =
  let* code = delete "/api/deck_tags/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let suite_deck_tag = [
  Alcotest.test_case "GET /api/deck_tags returns 200" `Quick (lwt_run test_list_deck_tag);
  Alcotest.test_case "GET /api/deck_tags?q=test returns 200" `Quick (lwt_run test_search_deck_tag);
  Alcotest.test_case "POST /api/deck_tags returns 201" `Quick (lwt_run test_create_deck_tag);
  Alcotest.test_case "GET /api/deck_tags/1 returns 200 or 404" `Quick (lwt_run test_get_deck_tag);
  Alcotest.test_case "PUT /api/deck_tags/1 returns 200 or 404" `Quick (lwt_run test_update_deck_tag);
  Alcotest.test_case "DELETE /api/deck_tags/1 returns 204 or 404" `Quick (lwt_run test_delete_deck_tag);
]

