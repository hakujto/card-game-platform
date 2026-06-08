(* Alcotest tests for PlayerSeasonStats — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "wins": 0,
    "losses": 0,
    "draws": 1,
    "tournament_wins": 0,
    "highest_rank": null,
    "season_points": 0,
    "player_id": 1,
    "season_id": 1
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

let test_list_player_season_stats () =
  let* code = get "/api/player_season_statses" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_get_player_season_stats () =
  let* code = get "/api/player_season_statses/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let suite_player_season_stats = [
  Alcotest.test_case "GET /api/player_season_statses returns 200" `Quick (lwt_run test_list_player_season_stats);
  Alcotest.test_case "GET /api/player_season_statses/1 returns 200 or 404" `Quick (lwt_run test_get_player_season_stats);
]

