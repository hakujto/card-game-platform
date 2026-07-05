(* Alcotest tests for Game — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_game_id = ref 0

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
  let dep_body_tournament = Printf.sprintf "{\n    \"public_id\": \"00000000-0000-0000-0000-000000000001\",\n    \"name\": \"test\",\n    \"description\": null,\n    \"status\": \"Draft\",\n    \"bracket_data\": null,\n    \"format\": \"Standard\",\n    \"tournament_type\": \"Swiss\",\n    \"max_players\": 1,\n    \"entry_fee\": 1.0,\n    \"prize_pool\": 1.0,\n    \"start_time\": \"2024-01-01T00:00:00Z\",\n    \"end_time\": null,\n    \"is_online\": false,\n    \"location\": null,\n    \"rules_text\": null,\n    \"season_id\": %d,\n    \"organizer_id\": %d\n  }" !(setup_season_id) !(setup_player_id) in
  let* (_, dep_id_tournament) = post_for_id "/api/tournaments" dep_body_tournament in
  setup_tournament_id := dep_id_tournament;
  let dep_body_tournament_round = Printf.sprintf "{\n    \"round_number\": 1,\n    \"status\": \"Pending\",\n    \"started_at\": null,\n    \"ended_at\": null,\n    \"time_limit_minutes\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* (_, dep_id_tournament_round) = post_for_id "/api/tournament_rounds" dep_body_tournament_round in
  setup_tournament_round_id := dep_id_tournament_round;
  let dep_body_match = Printf.sprintf "{\n    \"table_number\": null,\n    \"status\": \"Pending\",\n    \"player1_wins\": 1,\n    \"player2_wins\": 1,\n    \"started_at\": null,\n    \"ended_at\": null,\n    \"result_notes\": null,\n    \"round_id\": %d,\n    \"player1_id\": %d,\n    \"player2_id\": null\n  }" !(setup_tournament_round_id) !(setup_player_id) in
  let* (_, dep_id_match) = post_for_id "/api/matches" dep_body_match in
  setup_match_id := dep_id_match;
  let setup_body = Printf.sprintf "{\n    \"game_number\": 2,\n    \"winner_side\": \"Player1\",\n    \"complexity_score\": null,\n    \"ended_by\": null,\n    \"replay_url\": null,\n    \"match_id\": %d,\n    \"winner_id\": %d\n  }" !(setup_match_id) !(setup_player_id) in
  let* (_, main_id) = post_for_id "/api/games" setup_body in
  setup_game_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_game () =
  let* code = get "/api/games" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_game () =
  let create_body = Printf.sprintf "{\n    \"game_number\": 2,\n    \"winner_side\": \"Player1\",\n    \"complexity_score\": null,\n    \"ended_by\": null,\n    \"replay_url\": null,\n    \"match_id\": %d,\n    \"winner_id\": %d\n  }" !(setup_match_id) !(setup_player_id) in
  let* code = post "/api/games" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_game () =
  let url = Printf.sprintf "/api/games/%d" !setup_game_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_game_number_range () =
  (* Rule: game_number_range — body violates the condition *)
  let body = {json|{
    "game_number": 4,
    "winner_side": "Player1",
    "complexity_score": null,
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_turns_played_positive () =
  (* Rule: turns_played_positive — body violates the condition *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "Player1",
    "complexity_score": null,
    "turns_played": 0,
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_duration_positive () =
  (* Rule: duration_positive — body violates the condition *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "Player1",
    "complexity_score": null,
    "duration_seconds": 0,
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_draw_has_no_winner () =
  (* Rule: draw_has_no_winner — body violates the condition *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "Draw",
    "complexity_score": null,
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_non_draw_requires_winner () =
  (* Rule: non_draw_requires_winner — body violates the condition *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "Player1",
    "complexity_score": null,
    "ended_by": null,
    "replay_url": null,
    "match_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_game = [
  Alcotest.test_case "GET /api/games returns 200" `Quick (lwt_run test_list_game);
  Alcotest.test_case "POST /api/games returns 201" `Quick (lwt_run test_create_game);
  Alcotest.test_case "GET /api/games/<id> returns 200" `Quick (lwt_run test_get_game);
  Alcotest.test_case "POST /api/games rule game_number_range -> 422" `Quick (lwt_run test_rule_game_number_range);
  Alcotest.test_case "POST /api/games rule turns_played_positive -> 422" `Quick (lwt_run test_rule_turns_played_positive);
  Alcotest.test_case "POST /api/games rule duration_positive -> 422" `Quick (lwt_run test_rule_duration_positive);
  Alcotest.test_case "POST /api/games rule draw_has_no_winner -> 422" `Quick (lwt_run test_rule_draw_has_no_winner);
  Alcotest.test_case "POST /api/games rule non_draw_requires_winner -> 422" `Quick (lwt_run test_rule_non_draw_requires_winner);
]

