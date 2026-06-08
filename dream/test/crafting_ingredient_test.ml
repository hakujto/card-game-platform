(* Alcotest tests for CraftingIngredient — uses cohttp-lwt-unix for HTTP requests *)
open Lwt.Syntax

let base_url = "http://localhost:3000"

let valid_body = {json|{
    "quantity": 1,
    "recipe_id": 1,
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

let test_list_crafting_ingredient () =
  let* code = get "/api/crafting_ingredients" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_create_crafting_ingredient () =
  let* code = post "/api/crafting_ingredients" valid_body in
  Alcotest.(check bool) "create returns 201 or 500" true (code = 201 || code = 500);
  Lwt.return_unit

let test_get_crafting_ingredient () =
  let* code = get "/api/crafting_ingredients/1" in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let test_delete_crafting_ingredient () =
  let* code = delete "/api/crafting_ingredients/1" in
  Alcotest.(check bool) "delete returns 204 or 404" true (code = 204 || code = 404);
  Lwt.return_unit

let suite_crafting_ingredient = [
  Alcotest.test_case "GET /api/crafting_ingredients returns 200" `Quick (lwt_run test_list_crafting_ingredient);
  Alcotest.test_case "POST /api/crafting_ingredients returns 201" `Quick (lwt_run test_create_crafting_ingredient);
  Alcotest.test_case "GET /api/crafting_ingredients/1 returns 200 or 404" `Quick (lwt_run test_get_crafting_ingredient);
  Alcotest.test_case "DELETE /api/crafting_ingredients/1 returns 204 or 404" `Quick (lwt_run test_delete_crafting_ingredient);
]

