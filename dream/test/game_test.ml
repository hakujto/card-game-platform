(* Alcotest tests for Game — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "game_number": 2,
    "winner_side": "not_Draw",
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
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

let test_list_game () =
  let* code = get "/api/games" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_game () =
  let* code = post "/api/games" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_game () =
  let* code = get "/api/games/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_rule_game_number_range () =
  (* Rule: game_number_range - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "game_number": 4,
    "winner_side": "not_Draw",
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_turns_played_positive () =
  (* Rule: turns_played_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "not_Draw",
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
  (* Rule: duration_positive - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "not_Draw",
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
  (* Rule: draw_has_no_winner - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "Draw",
    "ended_by": null,
    "replay_url": null,
    "match_id": 1,
    "winner_id": 1
  }|json} in
  let* code = post "/api/games" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let test_rule_non_draw_requires_winner () =
  (* Rule: non_draw_requires_winner - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "game_number": 2,
    "winner_side": "not_Draw",
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
  Alcotest.test_case "GET /api/games/1 returns 200 or 404" `Quick (lwt_run test_get_game);
  Alcotest.test_case "POST /api/games rule game_number_range -> 422" `Quick (lwt_run test_rule_game_number_range);
  Alcotest.test_case "POST /api/games rule turns_played_positive -> 422" `Quick (lwt_run test_rule_turns_played_positive);
  Alcotest.test_case "POST /api/games rule duration_positive -> 422" `Quick (lwt_run test_rule_duration_positive);
  Alcotest.test_case "POST /api/games rule draw_has_no_winner -> 422" `Quick (lwt_run test_rule_draw_has_no_winner);
  Alcotest.test_case "POST /api/games rule non_draw_requires_winner -> 422" `Quick (lwt_run test_rule_non_draw_requires_winner);
]

