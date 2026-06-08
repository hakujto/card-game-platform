(* Dream handlers for DeckTag *)
open Lwt.Syntax

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let color = match member "color" j with `String s -> Some s | _ -> None in
  (name, color)

let handler_deck_tag (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/deck_tags - list with optional ?q= search *)
  | `GET, ["api"; "deck_tags"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Deck_tag_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Deck_tag_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Deck_tag_model.to_yojson (Deck_tag_model.row_to_t r) in
         j) filtered) in
       respond_json 200 json)

  (* POST /api/deck_tags - create *)
  | `POST, ["api"; "deck_tags"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       let params = extract_insert_params j in
       let* ins = Db.exec Deck_tag_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Deck_tag_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Deck_tag_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Deck_tag_model.to_yojson (Deck_tag_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found"))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/deck_tags/:id - get one *)
  | `GET, ["api"; "deck_tags"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Deck_tag_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Deck_tag_model.to_yojson (Deck_tag_model.row_to_t r) in
          respond_json 200 (j)))

  (* PATCH /api/deck_tags/:id - partial update *)
  | `PATCH, ["api"; "deck_tags"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          let params = extract_insert_params j in
          let (name, color) = params in
          let upd_params = (name, color, id) in
          let* upd = Db.exec Deck_tag_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Deck_tag_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Deck_tag_model.to_yojson (Deck_tag_model.row_to_t r) in
                respond_json 200 (j)))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* DELETE /api/deck_tags/:id *)
  | `DELETE, ["api"; "deck_tags"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Deck_tag_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* PATCH /api/deck-tags/{id}/rename - behavior rename *)
  | `PATCH, ["api"; "deck_tags"; id_str; "_id/rename"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior rename *)
       respond_json 204 (`Null))

  (* POST /api/deck-tags/{id}/merge - behavior merge_into *)
  | `POST, ["api"; "deck_tags"; id_str; "_id/merge"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior merge_into *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
