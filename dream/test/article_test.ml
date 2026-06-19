(* Alcotest tests for Article — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_article_id = ref 0

let do_setup () =
  let* (_, dep_id_player) = post_for_id "/api/players" {json|{
    "display_name": "test",
    "rank": "Bronze",
    "rating": 1,
    "peak_rating": 1,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  setup_player_id := dep_id_player;
  let setup_body = Printf.sprintf "{\n    \"title\": \"test\",\n    \"slug\": \"test2\",\n    \"body\": \"test\",\n    \"excerpt\": null,\n    \"cover_image_url\": null,\n    \"status\": \"not_Published\",\n    \"article_type\": \"Guide\",\n    \"language\": \"EN\",\n    \"view_count\": 0,\n    \"likes_count\": 0,\n    \"is_featured\": false,\n    \"published_at\": null,\n    \"author_id\": %d,\n    \"featured_deck_id\": null\n  }" !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/articles" setup_body in
  setup_article_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_article () =
  let* code = get "/api/articles" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_article () =
  let* code = get "/api/articles?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_article () =
  let create_body = Printf.sprintf "{\n    \"title\": \"test\",\n    \"slug\": \"test22\",\n    \"body\": \"test\",\n    \"excerpt\": null,\n    \"cover_image_url\": null,\n    \"status\": \"not_Published\",\n    \"article_type\": \"Guide\",\n    \"language\": \"EN\",\n    \"view_count\": 0,\n    \"likes_count\": 0,\n    \"is_featured\": false,\n    \"published_at\": null,\n    \"author_id\": %d,\n    \"featured_deck_id\": null\n  }" !(setup_player_id) in
  let* code = post "/api/articles" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_article () =
  let url = Printf.sprintf "/api/articles/%d" !setup_article_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_article () =
  let url = Printf.sprintf "/api/articles/%d" !setup_article_id in
  let update_body = Printf.sprintf "{\n    \"title\": \"test\",\n    \"slug\": \"test2\",\n    \"body\": \"test\",\n    \"excerpt\": null,\n    \"cover_image_url\": null,\n    \"status\": \"not_Published\",\n    \"article_type\": \"Guide\",\n    \"language\": \"EN\",\n    \"view_count\": 0,\n    \"likes_count\": 0,\n    \"is_featured\": false,\n    \"published_at\": null,\n    \"author_id\": %d,\n    \"featured_deck_id\": null\n  }" !(setup_player_id) in
  let* code = put url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_rule_published_requires_published_at () =
  (* Rule: published_requires_published_at — body violates the condition *)
  let body = {json|{
    "title": "test",
    "slug": "test2",
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
  (* Rule: view_count_not_negative — body violates the condition *)
  let body = {json|{
    "title": "test",
    "slug": "test2",
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
  (* Rule: likes_count_not_negative — body violates the condition *)
  let body = {json|{
    "title": "test",
    "slug": "test2",
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
  Alcotest.test_case "GET /api/articles/<id> returns 200" `Quick (lwt_run test_get_article);
  Alcotest.test_case "PUT /api/articles/<id> returns 200" `Quick (lwt_run test_update_article);
  Alcotest.test_case "POST /api/articles rule published_requires_published_at -> 422" `Quick (lwt_run test_rule_published_requires_published_at);
  Alcotest.test_case "POST /api/articles rule view_count_not_negative -> 422" `Quick (lwt_run test_rule_view_count_not_negative);
  Alcotest.test_case "POST /api/articles rule likes_count_not_negative -> 422" `Quick (lwt_run test_rule_likes_count_not_negative);
]

