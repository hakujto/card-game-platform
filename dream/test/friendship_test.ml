(* Alcotest tests for Friendship — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_friendship_id = ref 0

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
  let setup_body = Printf.sprintf "{\n    \"status\": \"Pending\",\n    \"requester_id\": %d,\n    \"receiver_id\": %d\n  }" !(setup_player_id) !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/friendships" setup_body in
  setup_friendship_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

(* Caller identity for ownership-guarded endpoints — must match the *)
(* <own_field>_id persisted on the main entity in setUp, or every  *)
(* GET/PATCH/DELETE below would 403 against its own record.        *)
let auth_headers = [("X-User-Id", string_of_int !setup_player_id)]

let test_list_friendship () =
  let* code = get "/api/friendships" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_friendship () =
  let create_body = Printf.sprintf "{\n    \"status\": \"Pending\",\n    \"requester_id\": %d,\n    \"receiver_id\": %d\n  }" !(setup_player_id) !(setup_player_id) in
  let* code = post ~headers:auth_headers "/api/friendships" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_friendship () =
  let url = Printf.sprintf "/api/friendships/%d" !setup_friendship_id in
  let* code = get ~headers:auth_headers url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_delete_friendship () =
  let url = Printf.sprintf "/api/friendships/%d" !setup_friendship_id in
  let* code = delete ~headers:auth_headers url in
  Alcotest.(check int) "delete returns 204" 204 code;
  Lwt.return_unit

let suite_friendship = [
  Alcotest.test_case "GET /api/friendships returns 200" `Quick (lwt_run test_list_friendship);
  Alcotest.test_case "POST /api/friendships returns 201" `Quick (lwt_run test_create_friendship);
  Alcotest.test_case "GET /api/friendships/<id> returns 200" `Quick (lwt_run test_get_friendship);
  Alcotest.test_case "DELETE /api/friendships/<id> returns 204" `Quick (lwt_run test_delete_friendship);
]

