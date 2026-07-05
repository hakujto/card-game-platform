(* Alcotest tests for TournamentPrize — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_tournament_prize_id = ref 0

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
  let setup_body = Printf.sprintf "{\n    \"placement_from\": 1,\n    \"placement_to\": 1,\n    \"prize_type\": \"Currency\",\n    \"amount\": 0,\n    \"description\": null,\n    \"packs_count\": null,\n    \"season_points\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* (_, main_id) = post_for_id "/api/tournament_prizes" setup_body in
  setup_tournament_prize_id := main_id;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_tournament_prize () =
  let* code = get "/api/tournament_prizes" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament_prize () =
  let create_body = Printf.sprintf "{\n    \"placement_from\": 1,\n    \"placement_to\": 1,\n    \"prize_type\": \"Currency\",\n    \"amount\": 0,\n    \"description\": null,\n    \"packs_count\": null,\n    \"season_points\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* code = post "/api/tournament_prizes" create_body in
  Alcotest.(check int) "create returns 201" 201 code;
  Lwt.return_unit

let test_get_tournament_prize () =
  let url = Printf.sprintf "/api/tournament_prizes/%d" !setup_tournament_prize_id in
  let* code = get url in
  Alcotest.(check int) "get returns 200" 200 code;
  Lwt.return_unit

let test_update_tournament_prize () =
  let url = Printf.sprintf "/api/tournament_prizes/%d" !setup_tournament_prize_id in
  let update_body = Printf.sprintf "{\n    \"placement_from\": 1,\n    \"placement_to\": 1,\n    \"prize_type\": \"Currency\",\n    \"amount\": 0,\n    \"description\": null,\n    \"packs_count\": null,\n    \"season_points\": 1,\n    \"tournament_id\": %d\n  }" !(setup_tournament_id) in
  let* code = put url update_body in
  Alcotest.(check int) "update returns 200" 200 code;
  Lwt.return_unit

let test_delete_tournament_prize () =
  let url = Printf.sprintf "/api/tournament_prizes/%d" !setup_tournament_prize_id in
  let* code = delete url in
  Alcotest.(check int) "delete returns 204" 204 code;
  Lwt.return_unit

let test_rule_placement_range_valid () =
  (* Rule: placement_range_valid — body violates the condition *)
  let body = {json|{
    "placement_from": 1,
    "placement_to": 0,
    "prize_type": "Currency",
    "amount": 0,
    "description": null,
    "packs_count": null,
    "season_points": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_prizes" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_placement_from_positive () =
  (* Rule: placement_from_positive — body violates the condition *)
  let body = {json|{
    "placement_from": 0,
    "placement_to": 1,
    "prize_type": "Currency",
    "amount": 0,
    "description": null,
    "packs_count": null,
    "season_points": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_prizes" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_amount_not_negative () =
  (* Rule: amount_not_negative — body violates the condition *)
  let body = {json|{
    "placement_from": 1,
    "placement_to": 1,
    "prize_type": "Currency",
    "amount": -1,
    "description": null,
    "packs_count": null,
    "season_points": 1,
    "tournament_id": 1
  }|json} in
  let* code = post "/api/tournament_prizes" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_tournament_prize = [
  Alcotest.test_case "GET /api/tournament_prizes returns 200" `Quick (lwt_run test_list_tournament_prize);
  Alcotest.test_case "POST /api/tournament_prizes returns 201" `Quick (lwt_run test_create_tournament_prize);
  Alcotest.test_case "GET /api/tournament_prizes/<id> returns 200" `Quick (lwt_run test_get_tournament_prize);
  Alcotest.test_case "PUT /api/tournament_prizes/<id> returns 200" `Quick (lwt_run test_update_tournament_prize);
  Alcotest.test_case "DELETE /api/tournament_prizes/<id> returns 204" `Quick (lwt_run test_delete_tournament_prize);
  Alcotest.test_case "POST /api/tournament_prizes rule placement_range_valid -> 422" `Quick (lwt_run test_rule_placement_range_valid);
  Alcotest.test_case "POST /api/tournament_prizes rule placement_from_positive -> 422" `Quick (lwt_run test_rule_placement_from_positive);
  Alcotest.test_case "POST /api/tournament_prizes rule amount_not_negative -> 422" `Quick (lwt_run test_rule_amount_not_negative);
]

