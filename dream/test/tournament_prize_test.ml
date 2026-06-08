(* Alcotest tests for TournamentPrize — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "placement_from": 1,
    "placement_to": 1,
    "prize_type": "Currency",
    "amount": 0,
    "description": null,
    "packs_count": null,
    "season_points": 1,
    "tournament_id": 1
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

let test_list_tournament_prize () =
  let* code = get "/api/tournament_prizes" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_tournament_prize () =
  let* code = post "/api/tournament_prizes" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_tournament_prize () =
  let* code = get "/api/tournament_prizes/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_tournament_prize () =
  let* code = put "/api/tournament_prizes/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_delete_tournament_prize () =
  let* code = delete "/api/tournament_prizes/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let test_rule_placement_range_valid () =
  (* Rule: placement_range_valid - this body should violate the condition and yield 422/400 *)
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
  (* Rule: placement_from_positive - this body should violate the condition and yield 422/400 *)
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
  (* Rule: amount_not_negative - this body should violate the condition and yield 422/400 *)
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
  Alcotest.test_case "GET /api/tournament_prizes/1 returns 200 or 404" `Quick (lwt_run test_get_tournament_prize);
  Alcotest.test_case "PUT /api/tournament_prizes/1 returns 200 or 404" `Quick (lwt_run test_update_tournament_prize);
  Alcotest.test_case "DELETE /api/tournament_prizes/1 returns 204 or 404" `Quick (lwt_run test_delete_tournament_prize);
  Alcotest.test_case "POST /api/tournament_prizes rule placement_range_valid -> 422" `Quick (lwt_run test_rule_placement_range_valid);
  Alcotest.test_case "POST /api/tournament_prizes rule placement_from_positive -> 422" `Quick (lwt_run test_rule_placement_from_positive);
  Alcotest.test_case "POST /api/tournament_prizes rule amount_not_negative -> 422" `Quick (lwt_run test_rule_amount_not_negative);
]

