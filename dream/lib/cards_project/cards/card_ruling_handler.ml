(* Dream handlers for CardRuling *)
open Lwt.Syntax

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let ruling_text = match member "ruling_text" j with `String s -> s | _ -> "" in
  let published_at = match member "published_at" j with `String s -> s | _ -> "" in
  let source = match member "source" j with `String s -> s | _ -> "" in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  (ruling_text, published_at, source, card_id)

let handler_card_ruling (db : (module Caqti_lwt.CONNECTION)) req =
  let respond_json status body =
    Dream.respond ~status:(Dream.int_to_status status)
      ~headers:[("Content-Type", "application/json")]
      (Yojson.Safe.to_string body)
  in
  let module Db = (val db) in
  let target_path = match String.index_opt (Dream.target req) '?' with
    | Some i -> String.sub (Dream.target req) 0 i
    | None -> Dream.target req
  in
  let path_segments = target_path |> String.split_on_char '/' |> List.filter (fun s -> s <> "") in
  match Dream.method_ req, path_segments with

  (* GET /api/card_rulings - list all *)
  | `GET, ["api"; "card_rulings"] ->
    let* rows = Db.collect_list Card_ruling_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Card_ruling_model.to_yojson (Card_ruling_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/card_rulings - create *)
  | `POST, ["api"; "card_rulings"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       let params = extract_insert_params j in
       let* ins = Db.exec Card_ruling_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Card_ruling_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Card_ruling_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Card_ruling_model.to_yojson (Card_ruling_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found"))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/card_rulings/:id - get one *)
  | `GET, ["api"; "card_rulings"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Card_ruling_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Card_ruling_model.to_yojson (Card_ruling_model.row_to_t r) in
          respond_json 200 (j)))

  (* DELETE /api/card_rulings/:id *)
  | `DELETE, ["api"; "card_rulings"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Card_ruling_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* GET /api/card-rulings/{id}/current - behavior is_current *)
  | `GET, ["api"; "card_rulings"; id_str; "_id/current"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_current *)
       respond_json 204 (`Null))

  (* GET /api/card-rulings/{id}/supersedes - behavior supersedes_previous *)
  | `GET, ["api"; "card_rulings"; id_str; "_id/supersedes"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior supersedes_previous *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
