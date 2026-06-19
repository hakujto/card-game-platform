(* Alcotest tests for TournamentRegistration — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_deck_id = ref 0
let setup_tournament_registration_id = ref 0

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
  let dep_body_deck = Printf.sprintf "{\n    \"name\": \"test\",\n    \"description\": null,\n    \"format\": \"Standard\",\n    \"is_public\": false,\n    \"is_tournament_legal\": false,\n    \"archetype\": null,\n    \"wins\": 1,\n    \"losses\": 1,\n    \"draws\": 1,\n    \"player_id\": %d\n  }" !(setup_player_id) in
  let* (_, dep_id_deck) = post_for_id "/api/decks" dep_body_deck in
  setup_deck_id := dep_id_deck;
  let setup_body = Printf.sprintf "{\n    \"status\": \"Registered\",\n    \"points_earned\": 0,\n    \"registered_at\": \"2024-01-01T00:00:00Z\",\n    \"tournament_id\": %d,\n    \"player_id\": %d,\n    \"deck_id\": %d\n  }" !(setup_tournament_id) !(setup_player_id) !(setup_deck_id) in
  let* (_, main_id) = post_for_id "/api/tournament_registrations" setup_body in
  setup_tournament_registration_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

(* Caller identity for ownership-guarded endpoints — must match the *)
(* <own_field>_id persisted on the main entity in setUp, or every  *)
(* GET/PATCH/DELETE below would 403 against its own record.        *)
let auth_headers = [("X-User-Id", string_of_int !setup_player_id)]

let test_list_tournament_registration () =
  let* code = get "/api/tournament_registrations" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament_registration () =
  let create_body = Printf.sprintf "{\n    \"status\": \"Registered\",\n    \"points_earned\": 0,\n    \"registered_at\": \"2024-01-01T00:00:00Z\",\n    \"tournament_id\": %d,\n    \"player_id\": %d,\n    \"deck_id\": %d\n  }" !(setup_tournament_id) !(setup_player_id) !(setup_deck_id) in
  let* code = post ~headers:auth_headers "/api/tournament_registrations" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_tournament_registration () =
  let url = Printf.sprintf "/api/tournament_registrations/%d" !setup_tournament_registration_id in
  let* code = get ~headers:auth_headers url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_rule_points_earned_not_negative () =
  (* Rule: points_earned_not_negative — body violates the condition *)
  let body = {json|{
    "status": "Registered",
    "points_earned": -1,
    "registered_at": "2024-01-01T00:00:00Z",
    "tournament_id": 1,
    "player_id": 1,
    "deck_id": 1
  }|json} in
  let* code = post "/api/tournament_registrations" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_final_standing_positive () =
  (* Rule: final_standing_positive — body violates the condition *)
  let body = {json|{
    "status": "Registered",
    "final_standing": 0,
    "points_earned": 0,
    "registered_at": "2024-01-01T00:00:00Z",
    "tournament_id": 1,
    "player_id": 1,
    "deck_id": 1
  }|json} in
  let* code = post "/api/tournament_registrations" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_seed_positive () =
  (* Rule: seed_positive — body violates the condition *)
  let body = {json|{
    "status": "Registered",
    "seed": 0,
    "points_earned": 0,
    "registered_at": "2024-01-01T00:00:00Z",
    "tournament_id": 1,
    "player_id": 1,
    "deck_id": 1
  }|json} in
  let* code = post "/api/tournament_registrations" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_tournament_registration = [
  Alcotest.test_case "GET /api/tournament_registrations returns 200" `Quick (lwt_run test_list_tournament_registration);
  Alcotest.test_case "POST /api/tournament_registrations returns 201" `Quick (lwt_run test_create_tournament_registration);
  Alcotest.test_case "GET /api/tournament_registrations/<id> returns 200" `Quick (lwt_run test_get_tournament_registration);
  Alcotest.test_case "POST /api/tournament_registrations rule points_earned_not_negative -> 422" `Quick (lwt_run test_rule_points_earned_not_negative);
  Alcotest.test_case "POST /api/tournament_registrations rule final_standing_positive -> 422" `Quick (lwt_run test_rule_final_standing_positive);
  Alcotest.test_case "POST /api/tournament_registrations rule seed_positive -> 422" `Quick (lwt_run test_rule_seed_positive);
]

