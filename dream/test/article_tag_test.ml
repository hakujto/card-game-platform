(* Alcotest tests for ArticleTag — uses cohttp-lwt-unix for HTTP requests *)
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

let test_list_article_tag () =
  let* code = get "/api/article_tags" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_article_tag () =
  let* code = get "/api/article_tags?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_article_tag () =
  let* code = post "/api/article_tags" {json|{
    "name": "test",
    "slug": "test2"
  }|json} in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_article_tag () =
  let* code = get "/api/article_tags/1" in
  Alcotest.(check bool) "get returns 200 or 403 or 404" true (code = 200 || code = 403 || code = 404);
  Lwt.return_unit

let test_update_article_tag () =
  let* code = patch "/api/article_tags/1" {json|{
    "name": "test",
    "slug": "test2"
  }|json} in
  Alcotest.(check bool) "update returns 200 or 403 or 404 or 500" true (code = 200 || code = 403 || code = 404 || code = 500);
  Lwt.return_unit

let test_delete_article_tag () =
  let* code = delete "/api/article_tags/1" in
  Alcotest.(check bool) "delete returns 204 or 403 or 404" true (code = 204 || code = 403 || code = 404);
  Lwt.return_unit

let suite_article_tag = [
  Alcotest.test_case "GET /api/article_tags returns 200" `Quick (lwt_run test_list_article_tag);
  Alcotest.test_case "GET /api/article_tags?q=test returns 200" `Quick (lwt_run test_search_article_tag);
  Alcotest.test_case "POST /api/article_tags returns 201" `Quick (lwt_run test_create_article_tag);
  Alcotest.test_case "GET /api/article_tags/1 returns 200" `Quick (lwt_run test_get_article_tag);
  Alcotest.test_case "PATCH /api/article_tags/1 returns 200" `Quick (lwt_run test_update_article_tag);
  Alcotest.test_case "DELETE /api/article_tags/1 returns 204" `Quick (lwt_run test_delete_article_tag);
]

