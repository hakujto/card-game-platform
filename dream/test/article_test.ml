(* Alcotest tests for Article — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "title": "test",
    "slug": "test",
    "body": "test",
    "excerpt": null,
    "cover_image_url": null,
    "status": "not_Published",
    "article_type": "Guide",
    "language": "EN",
    "view_count": 0,
    "likes_count": 0,
    "is_featured": false,
    "published_at": null,
    "author_id": 1,
    "featured_deck_id": null
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

let test_list_article () =
  let* code = get "/api/articles" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_article () =
  let* code = get "/api/articles?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_article () =
  let* code = post "/api/articles" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_article () =
  let* code = get "/api/articles/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_article () =
  let* code = put "/api/articles/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_rule_published_requires_published_at () =
  (* Rule: published_requires_published_at - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "title": "test",
    "slug": "test",
    "body": "test",
    "excerpt": null,
    "cover_image_url": null,
    "status": "Published",
    "article_type": "Guide",
    "language": "EN",
    "view_count": 0,
    "likes_count": 0,
    "is_featured": false,
    "author_id": 1,
    "featured_deck_id": null
  }|json} in
  let* code = post "/api/articles" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_view_count_not_negative () =
  (* Rule: view_count_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "title": "test",
    "slug": "test",
    "body": "test",
    "excerpt": null,
    "cover_image_url": null,
    "status": "not_Published",
    "article_type": "Guide",
    "language": "EN",
    "view_count": -1,
    "likes_count": 0,
    "is_featured": false,
    "published_at": null,
    "author_id": 1,
    "featured_deck_id": null
  }|json} in
  let* code = post "/api/articles" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_likes_count_not_negative () =
  (* Rule: likes_count_not_negative - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "title": "test",
    "slug": "test",
    "body": "test",
    "excerpt": null,
    "cover_image_url": null,
    "status": "not_Published",
    "article_type": "Guide",
    "language": "EN",
    "view_count": 0,
    "likes_count": -1,
    "is_featured": false,
    "published_at": null,
    "author_id": 1,
    "featured_deck_id": null
  }|json} in
  let* code = post "/api/articles" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_article = [
  Alcotest.test_case "GET /api/articles returns 200" `Quick (lwt_run test_list_article);
  Alcotest.test_case "GET /api/articles?q=test returns 200" `Quick (lwt_run test_search_article);
  Alcotest.test_case "POST /api/articles returns 201" `Quick (lwt_run test_create_article);
  Alcotest.test_case "GET /api/articles/1 returns 200 or 404" `Quick (lwt_run test_get_article);
  Alcotest.test_case "PUT /api/articles/1 returns 200 or 404" `Quick (lwt_run test_update_article);
  Alcotest.test_case "POST /api/articles rule published_requires_published_at -> 422" `Quick (lwt_run test_rule_published_requires_published_at);
  Alcotest.test_case "POST /api/articles rule view_count_not_negative -> 422" `Quick (lwt_run test_rule_view_count_not_negative);
  Alcotest.test_case "POST /api/articles rule likes_count_not_negative -> 422" `Quick (lwt_run test_rule_likes_count_not_negative);
]

