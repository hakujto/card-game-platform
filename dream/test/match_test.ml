(* Alcotest tests for Match — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_tournament_round_id = ref 0
let setup_match_id = ref 0

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
  let dep_body_tournament = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"status\": \"Draft\",\n    \"format\": \"Standard\",\n    \"tournament_type\": \"Swiss\",\n    \"max_players\": 1,\n    \"entry_fee\": 1.0,\n    \"prize_pool\": 1.0,\n    \"start_time\": \"2024-01-01T00:00:00Z\",\n    \"end_time\": null,\n    \"is_online\": false,\n    \"location\": null,\n    \"rules_text\": null,\n    \"season_id\": %d,\n    \"organizer_id\": %d\n  }" !(setup_season_id) !(setup_player_id) in
  let* (_, dep_id_tournament) = post_for_id "/api/tournaments" dep_body_tournament in
  setup_tournament_id := dep_id_tournament;
  let dep_body_tournament_round = Printf.sprintf "{\n    \"round_number\": 1,\n    \"status\": \"Pending\",\n    \"started_at\": null,\n    \"ended_at\": null,\n    \"time_limit_minutes\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* (_, dep_id_tournament_round) = post_for_id "/api/tournament_rounds" dep_body_tournament_round in
  setup_tournament_round_id := dep_id_tournament_round;
  let setup_body = Printf.sprintf "{\n    \"table_number\": null,\n    \"status\": \"not_BYE\",\n    \"player1_wins\": 0,\n    \"player2_wins\": 0,\n    \"started_at\": null,\n    \"result_notes\": null,\n    \"round_id\": %d,\n    \"player1_id\": %d,\n    \"player2_id\": null\n  }" !(setup_tournament_round_id) !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/matches" setup_body in
  setup_match_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_match () =
  let* code = get "/api/matches" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_match () =
  let create_body = Printf.sprintf "{\n    \"table_number\": null,\n    \"status\": \"not_BYE\",\n    \"player1_wins\": 0,\n    \"player2_wins\": 0,\n    \"started_at\": null,\n    \"result_notes\": null,\n    \"round_id\": %d,\n    \"player1_id\": %d,\n    \"player2_id\": null\n  }" !(setup_tournament_round_id) !(setup_player_id) in
  let* code = post "/api/matches" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_match () =
  let url = Printf.sprintf "/api/matches/%d" !setup_match_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_wins_not_negative () =
  (* Rule: wins_not_negative — body violates the condition *)
  let body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 0,
    "player2_wins": -1,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_max_three_games () =
  (* Rule: max_three_games — body violates the condition *)
  let body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 3,
    "player2_wins": 0,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_bye_has_no_player2 () =
  (* Rule: bye_has_no_player2 — body violates the condition *)
  let body = {json|{
    "table_number": null,
    "status": "BYE",
    "player1_wins": 0,
    "player2_wins": 0,
    "started_at": null,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": 1
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_ended_after_started () =
  (* Rule: ended_after_started — body violates the condition *)
  let body = {json|{
    "table_number": null,
    "status": "not_BYE",
    "player1_wins": 0,
    "player2_wins": 0,
    "started_at": null,
    "ended_at": 0,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_completed_requires_started_at () =
  (* Rule: completed_requires_started_at — body violates the condition *)
  let body = {json|{
    "table_number": null,
    "status": "Completed",
    "player1_wins": 0,
    "player2_wins": 0,
    "result_notes": null,
    "round_id": 1,
    "player1_id": 1,
    "player2_id": null
  }|json} in
  let* code = post "/api/matches" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_match = [
  Alcotest.test_case "GET /api/matches returns 200" `Quick (lwt_run test_list_match);
  Alcotest.test_case "POST /api/matches returns 201" `Quick (lwt_run test_create_match);
  Alcotest.test_case "GET /api/matches/<id> returns 200" `Quick (lwt_run test_get_match);
  Alcotest.test_case "POST /api/matches rule wins_not_negative -> 422" `Quick (lwt_run test_rule_wins_not_negative);
  Alcotest.test_case "POST /api/matches rule max_three_games -> 422" `Quick (lwt_run test_rule_max_three_games);
  Alcotest.test_case "POST /api/matches rule bye_has_no_player2 -> 422" `Quick (lwt_run test_rule_bye_has_no_player2);
  Alcotest.test_case "POST /api/matches rule ended_after_started -> 422" `Quick (lwt_run test_rule_ended_after_started);
  Alcotest.test_case "POST /api/matches rule completed_requires_started_at -> 422" `Quick (lwt_run test_rule_completed_requires_started_at);
]

