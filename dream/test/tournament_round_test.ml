(* Alcotest tests for TournamentRound — uses cohttp-lwt-unix for HTTP requests *)
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
  let setup_body = Printf.sprintf "{\n    \"round_number\": 1,\n    \"status\": \"Pending\",\n    \"started_at\": null,\n    \"time_limit_minutes\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* (_, main_id) = post_for_id "/api/tournament_rounds" setup_body in
  setup_tournament_round_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_tournament_round () =
  let* code = get "/api/tournament_rounds" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament_round () =
  let create_body = Printf.sprintf "{\n    \"round_number\": 1,\n    \"status\": \"Pending\",\n    \"started_at\": null,\n    \"time_limit_minutes\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* code = post "/api/tournament_rounds" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_tournament_round () =
  let url = Printf.sprintf "/api/tournament_rounds/%d" !setup_tournament_round_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_ended_after_started () =
  (* Rule: ended_after_started — body violates the condition *)
  let body = {json|{
    "round_number": 1,
    "status": "Pending",
    "started_at": null,
    "ended_at": 0,
    "time_limit_minutes": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_completed_requires_started_at () =
  (* Rule: completed_requires_started_at — body violates the condition *)
  let body = {json|{
    "round_number": 1,
    "status": "Completed",
    "time_limit_minutes": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_round_number_positive () =
  (* Rule: round_number_positive — body violates the condition *)
  let body = {json|{
    "round_number": 0,
    "status": "Pending",
    "started_at": null,
    "time_limit_minutes": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_time_limit_positive () =
  (* Rule: time_limit_positive — body violates the condition *)
  let body = {json|{
    "round_number": 1,
    "status": "Pending",
    "started_at": null,
    "time_limit_minutes": 0,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_rounds" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_tournament_round = [
  Alcotest.test_case "GET /api/tournament_rounds returns 200" `Quick (lwt_run test_list_tournament_round);
  Alcotest.test_case "POST /api/tournament_rounds returns 201" `Quick (lwt_run test_create_tournament_round);
  Alcotest.test_case "GET /api/tournament_rounds/<id> returns 200" `Quick (lwt_run test_get_tournament_round);
  Alcotest.test_case "POST /api/tournament_rounds rule ended_after_started -> 422" `Quick (lwt_run test_rule_ended_after_started);
  Alcotest.test_case "POST /api/tournament_rounds rule completed_requires_started_at -> 422" `Quick (lwt_run test_rule_completed_requires_started_at);
  Alcotest.test_case "POST /api/tournament_rounds rule round_number_positive -> 422" `Quick (lwt_run test_rule_round_number_positive);
  Alcotest.test_case "POST /api/tournament_rounds rule time_limit_positive -> 422" `Quick (lwt_run test_rule_time_limit_positive);
]

