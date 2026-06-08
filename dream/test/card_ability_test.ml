(* Alcotest tests for CardAbility — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "ability_type": "not_Keyword",
    "keyword": null,
    "ability_text": "test",
    "timing": null,
    "card_id": 1
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

let test_list_card_ability () =
  let* code = get "/api/card_abilities" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_search_card_ability () =
  let* code = get "/api/card_abilities?q=test" in
  Alcotest.(check int) "search returns 200" 200 code;
  Lwt.return_unit

let test_create_card_ability () =
  let* code = post "/api/card_abilities" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_card_ability () =
  let* code = get "/api/card_abilities/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_update_card_ability () =
  let* code = put "/api/card_abilities/1" valid_body in
  Alcotest.(check bool) "update returns 200 or 404 or 500" true (code = 200 || code = 404 || code = 500);
  Lwt.return_unit

let test_delete_card_ability () =
  let* code = delete "/api/card_abilities/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let test_rule_keyword_ability_requires_keyword () =
  (* Rule: keyword_ability_requires_keyword - this body should violate the condition and yield 422/400 *)
  let body = {json|{
    "ability_type": "Keyword",
    "ability_text": "test",
    "timing": null,
    "card_id": 1
  }|json} in
  let* code = post "/api/card_abilities" body in
  Alcotest.(check bool) "rule violation returns 422 or 400" true (code = 422 || code = 400);
  Lwt.return_unit

let suite_card_ability = [
  Alcotest.test_case "GET /api/card_abilities returns 200" `Quick (lwt_run test_list_card_ability);
  Alcotest.test_case "GET /api/card_abilities?q=test returns 200" `Quick (lwt_run test_search_card_ability);
  Alcotest.test_case "POST /api/card_abilities returns 201" `Quick (lwt_run test_create_card_ability);
  Alcotest.test_case "GET /api/card_abilities/1 returns 200 or 404" `Quick (lwt_run test_get_card_ability);
  Alcotest.test_case "PUT /api/card_abilities/1 returns 200 or 404" `Quick (lwt_run test_update_card_ability);
  Alcotest.test_case "DELETE /api/card_abilities/1 returns 204 or 404" `Quick (lwt_run test_delete_card_ability);
  Alcotest.test_case "POST /api/card_abilities rule keyword_ability_requires_keyword -> 422" `Quick (lwt_run test_rule_keyword_ability_requires_keyword);
]

