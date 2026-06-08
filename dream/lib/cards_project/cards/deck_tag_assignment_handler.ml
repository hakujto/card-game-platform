(* Dream handlers for DeckTagAssignment *)
open Lwt.Syntax

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let deck_id = match member "deck_id" j with `Int i -> i | _ -> 0 in
  let tag_id = match member "tag_id" j with `Int i -> i | _ -> 0 in
  (deck_id, tag_id)

let handler_deck_tag_assignment (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/deck_tag_assignments - list all *)
  | `GET, ["api"; "deck_tag_assignments"] ->
    let* rows = Db.collect_list Deck_tag_assignment_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Deck_tag_assignment_model.to_yojson (Deck_tag_assignment_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/deck_tag_assignments - create *)
  | `POST, ["api"; "deck_tag_assignments"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       let params = extract_insert_params j in
       let* ins = Db.exec Deck_tag_assignment_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Deck_tag_assignment_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Deck_tag_assignment_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Deck_tag_assignment_model.to_yojson (Deck_tag_assignment_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found"))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/deck_tag_assignments/:id - get one *)
  | `GET, ["api"; "deck_tag_assignments"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Deck_tag_assignment_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Deck_tag_assignment_model.to_yojson (Deck_tag_assignment_model.row_to_t r) in
          respond_json 200 (j)))

  (* DELETE /api/deck_tag_assignments/:id *)
  | `DELETE, ["api"; "deck_tag_assignments"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Deck_tag_assignment_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  | _ -> respond_json 404 (`String "Not found")
