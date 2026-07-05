(* Alcotest tests for ArticleComment — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_article_comment_id = ref 0

let do_setup () =
  let* (_, dep_id_player) = post_for_id "/api/players" {json|{
    "public_id": "00000000-0000-0000-0000-000000000001",
    "display_name": "test",
    "rank": "Bronze",
    "rating": 1,
    "peak_rating": 1,
    "bio": null,
    "country_code": null,
    "avatar_url": null,
    "preferred_format": null,
    "contact_email": null,
    "win_rate_cached": null,
    "is_verified": false,
    "last_active_at": null,
    "user_id": null
  }|json} in
  setup_player_id := dep_id_player;
  let dep_body_article = Printf.sprintf "{\n    \"title\": \"test\",\n    \"slug\": \"test\",\n    \"body\": \"test\",\n    \"excerpt\": null,\n    \"cover_image_url\": null,\n    \"status\": \"Draft\",\n    \"article_type\": \"Guide\",\n    \"language\": \"EN\",\n    \"view_count\": 1,\n    \"likes_count\": 1,\n    \"total_views_alltime\": 1,\n    \"is_featured\": false,\n    \"published_at\": null,\n    \"author_id\": %d,\n    \"featured_deck_id\": null\n  }" !(setup_player_id) in
  let* (_, dep_id_article) = post_for_id "/api/articles" dep_body_article in
  setup_article_id := dep_id_article;
  let setup_body = Printf.sprintf "{\n    \"body\": \"test\",\n    \"is_hidden\": false,\n    \"article_id\": %d,\n    \"author_id\": %d,\n    \"parent_comment_id\": null\n  }" !(setup_article_id) !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/article_comments" setup_body in
  setup_article_comment_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_article_comment () =
  let* code = get "/api/article_comments" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_article_comment () =
  let create_body = Printf.sprintf "{\n    \"body\": \"test\",\n    \"is_hidden\": false,\n    \"article_id\": %d,\n    \"author_id\": %d,\n    \"parent_comment_id\": null\n  }" !(setup_article_id) !(setup_player_id) in
  let* code = post "/api/article_comments" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_article_comment () =
  let url = Printf.sprintf "/api/article_comments/%d" !setup_article_comment_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_delete_article_comment () =
  let url = Printf.sprintf "/api/article_comments/%d" !setup_article_comment_id in
  let* code = delete url in
  Alcotest.(check int) "delete returns 204" 204 code;
  Lwt.return_unit

let suite_article_comment = [
  Alcotest.test_case "GET /api/article_comments returns 200" `Quick (lwt_run test_list_article_comment);
  Alcotest.test_case "POST /api/article_comments returns 201" `Quick (lwt_run test_create_article_comment);
  Alcotest.test_case "GET /api/article_comments/<id> returns 200" `Quick (lwt_run test_get_article_comment);
  Alcotest.test_case "DELETE /api/article_comments/<id> returns 204" `Quick (lwt_run test_delete_article_comment);
]

