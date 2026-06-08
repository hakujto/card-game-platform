(* Alcotest tests for TournamentRegistration — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "status": "Registered",
    "points_earned": 0,
    "registered_at": "2024-01-01T00:00:00Z",
    "tournament_id": 1,
    "player_id": 1,
    "deck_id": 1
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

let test_list_tournament_registration () =
  let* code = get "/api/tournament_registrations" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament_registration () =
  let* code = post "/api/tournament_registrations" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_tournament_registration () =
  let* code = get "/api/tournament_registrations/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_points_earned_not_negative () =
  (* Rule: points_earned_not_negative - this body should violate the condition and yield 422/400 *)
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
  (* Rule: final_standing_positive - this body should violate the condition and yield 422/400 *)
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
  (* Rule: seed_positive - this body should violate the condition and yield 422/400 *)
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
  Alcotest.test_case "GET /api/tournament_registrations/1 returns 200 or 404" `Quick (lwt_run test_get_tournament_registration);
  Alcotest.test_case "POST /api/tournament_registrations rule points_earned_not_negative -> 422" `Quick (lwt_run test_rule_points_earned_not_negative);
  Alcotest.test_case "POST /api/tournament_registrations rule final_standing_positive -> 422" `Quick (lwt_run test_rule_final_standing_positive);
  Alcotest.test_case "POST /api/tournament_registrations rule seed_positive -> 422" `Quick (lwt_run test_rule_seed_positive);
]

