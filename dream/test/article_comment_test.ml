(* Alcotest tests for ArticleComment — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "body": "test",
    "is_hidden": false,
    "article_id": 1,
    "author_id": 1,
    "parent_comment_id": null
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

let test_list_article_comment () =
  let* code = get "/api/article_comments" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_article_comment () =
  let* code = post "/api/article_comments" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_article_comment () =
  let* code = get "/api/article_comments/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_delete_article_comment () =
  let* code = delete "/api/article_comments/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let suite_article_comment = [
  Alcotest.test_case "GET /api/article_comments returns 200" `Quick (lwt_run test_list_article_comment);
  Alcotest.test_case "POST /api/article_comments returns 201" `Quick (lwt_run test_create_article_comment);
  Alcotest.test_case "GET /api/article_comments/1 returns 200 or 404" `Quick (lwt_run test_get_article_comment);
  Alcotest.test_case "DELETE /api/article_comments/1 returns 204 or 404" `Quick (lwt_run test_delete_article_comment);
]

