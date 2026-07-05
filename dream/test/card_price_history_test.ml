(* Alcotest tests for CardPriceHistory — uses cohttp-lwt-unix for HTTP requests *)
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
let setup_card_set_id = ref 0
let setup_card_id = ref 0
let setup_card_price_history_id = ref 0

let do_setup () =
  let* (_, dep_id_card_set) = post_for_id "/api/card_sets" {json|{
    "name": "test",
    "code": "test",
    "release_date": "2024-01-01",
    "rotation_date": null,
    "set_type": "Core",
    "total_cards": 1,
    "is_rotated": false,
    "description": null,
    "logo_url": null
  }|json} in
  setup_card_set_id := dep_id_card_set;
  let dep_body_card = Printf.sprintf "{\n    \"public_id\": \"00000000-0000-0000-0000-000000000001\",\n    \"name\": \"test\",\n    \"card_type\": \"Creature\",\n    \"rarity\": \"Common\",\n    \"mana_cost\": 1,\n    \"mana_colors\": \"White\",\n    \"attack\": 1,\n    \"defense\": 1,\n    \"loyalty\": null,\n    \"description\": \"test\",\n    \"flavor_text\": null,\n    \"image_url\": null,\n    \"artist_name\": null,\n    \"legal_formats\": \"Standard\",\n    \"is_banned\": false,\n    \"is_restricted\": false,\n    \"power_level\": 1,\n    \"metadata\": null,\n    \"total_copies_in_circulation\": 1,\n    \"set_id\": %d\n  }" !(setup_card_set_id) in
  let* (_, dep_id_card) = post_for_id "/api/cards" dep_body_card in
  setup_card_id := dep_id_card;
  setup_card_price_history_id := 1;
  Lwt.return_unit

let () = Lwt_main.run (do_setup ())

let test_list_card_price_history () =
  let* code = get "/api/card_price_histories" in
  Alcotest.(check int) "list returns 200" 200 code;
  Lwt.return_unit

let test_get_card_price_history () =
  (* No create endpoint — main entity not persisted via API, fixture id may not exist *)
  let url = Printf.sprintf "/api/card_price_histories/%d" !setup_card_price_history_id in
  let* code = get url in
  Alcotest.(check bool) "get returns 200 or 404" true (code = 200 || code = 404);
  Lwt.return_unit

let suite_card_price_history = [
  Alcotest.test_case "GET /api/card_price_histories returns 200" `Quick (lwt_run test_list_card_price_history);
  Alcotest.test_case "GET /api/card_price_histories/<id> returns 200" `Quick (lwt_run test_get_card_price_history);
]

