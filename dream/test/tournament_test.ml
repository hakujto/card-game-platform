(* Alcotest tests for Tournament — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_season_id = ref 0
let setup_player_id = ref 0
let setup_tournament_id = ref 0

let do_setup () =
  let* (_, dep_id_season) = post_for_id "/api/seasons" {json|{
    "name": "test",
    "start_date": "2024-01-01",
    "end_date": "2024-01-01",
    "format": "Standard",
    "is_active": false,
    "reward_description": null
  }|json} in
  setup_season_id := dep_id_season;
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
  let setup_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"status\": \"Draft\",\n    \"format\": \"Standard\",\n    \"tournament_type\": \"Swiss\",\n    \"max_players\": 257,\n    \"entry_fee\": 0,\n    \"prize_pool\": 0,\n    \"start_time\": \"2024-01-01T00:00:00Z\",\n    \"is_online\": false,\n    \"location\": null,\n    \"rules_text\": null,\n    \"season_id\": %d,\n    \"organizer_id\": %d\n  }" !(setup_season_id) !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/tournaments" setup_body in
  setup_tournament_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_tournament () =
  let* code = get "/api/tournaments" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_tournament () =
  let* code = get "/api/tournaments?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament () =
  let create_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"status\": \"Draft\",\n    \"format\": \"Standard\",\n    \"tournament_type\": \"Swiss\",\n    \"max_players\": 257,\n    \"entry_fee\": 0,\n    \"prize_pool\": 0,\n    \"start_time\": \"2024-01-01T00:00:00Z\",\n    \"is_online\": false,\n    \"location\": null,\n    \"rules_text\": null,\n    \"season_id\": %d,\n    \"organizer_id\": %d\n  }" !(setup_season_id) !(setup_player_id) in
  let* code = post "/api/tournaments" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_tournament () =
  let url = Printf.sprintf "/api/tournaments/%d" !setup_tournament_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_tournament () =
  let url = Printf.sprintf "/api/tournaments/%d" !setup_tournament_id in
  let update_body = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"status\": \"Draft\",\n    \"format\": \"Standard\",\n    \"tournament_type\": \"Swiss\",\n    \"max_players\": 257,\n    \"entry_fee\": 0,\n    \"prize_pool\": 0,\n    \"start_time\": \"2024-01-01T00:00:00Z\",\n    \"is_online\": false,\n    \"location\": null,\n    \"rules_text\": null,\n    \"season_id\": %d,\n    \"organizer_id\": %d\n  }" !(setup_season_id) !(setup_player_id) in
  let* code = put url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_rule_max_players_positive () =
  (* Rule: max_players_positive — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 513,
    "entry_fee": 0,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_entry_fee_not_negative () =
  (* Rule: entry_fee_not_negative — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": -1,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_prize_pool_not_negative () =
  (* Rule: prize_pool_not_negative — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": 0,
    "prize_pool": -1,
    "start_time": "2024-01-01T00:00:00Z",
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_end_time_after_start () =
  (* Rule: end_time_after_start — body violates the condition *)
  let body = {json|{
    "name": "test",
    "description": null,
    "status": "Draft",
    "format": "Standard",
    "tournament_type": "Swiss",
    "max_players": 257,
    "entry_fee": 0,
    "prize_pool": 0,
    "start_time": "2024-01-01T00:00:00Z",
    "end_time": 0,
    "is_online": false,
    "location": null,
    "rules_text": null,
    "season_id": 1,
    "organizer_id": 1
  }|json} in
  let* code = post "/api/tournaments" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_tournament = [
  Alcotest.test_case "GET /api/tournaments returns 200" `Quick (lwt_run test_list_tournament);
  Alcotest.test_case "GET /api/tournaments?q=test returns 200" `Quick (lwt_run test_search_tournament);
  Alcotest.test_case "POST /api/tournaments returns 201" `Quick (lwt_run test_create_tournament);
  Alcotest.test_case "GET /api/tournaments/<id> returns 200" `Quick (lwt_run test_get_tournament);
  Alcotest.test_case "PUT /api/tournaments/<id> returns 200" `Quick (lwt_run test_update_tournament);
  Alcotest.test_case "POST /api/tournaments rule max_players_positive -> 422" `Quick (lwt_run test_rule_max_players_positive);
  Alcotest.test_case "POST /api/tournaments rule entry_fee_not_negative -> 422" `Quick (lwt_run test_rule_entry_fee_not_negative);
  Alcotest.test_case "POST /api/tournaments rule prize_pool_not_negative -> 422" `Quick (lwt_run test_rule_prize_pool_not_negative);
  Alcotest.test_case "POST /api/tournaments rule end_time_after_start -> 422" `Quick (lwt_run test_rule_end_time_after_start);
]

