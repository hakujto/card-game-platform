(* Dream handlers for PlayerCollection *)
open Lwt.Syntax

let apply_projection_player_collection (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "acquired_at" then ("acquired_at", v) else (k, v)) fields in
    `Assoc fields
  | other -> other

(* JSON field helpers *)
let json_string_opt j key =
  match Yojson.Safe.Util.member key j with
  | `String s -> Some s
  | `Null | `Assoc [] -> None
  | _ -> None

let json_float_opt j key =
  match Yojson.Safe.Util.member key j with
  | `Float f -> Some f
  | `Int i -> Some (float_of_int i)
  | `String s -> (try Some (float_of_string s) with _ -> None)
  | _ -> None

let json_present j key =
  match Yojson.Safe.Util.member key j with
  | `Null | `Assoc [] -> false
  | _ -> true

let json_bool_opt j key =
  match Yojson.Safe.Util.member key j with
  | `Bool b -> Some b
  | _ -> None

let validate_player_collection (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "quantity") with Some v -> v > 0. | None -> true)) then errors := "Collection quantity must be greater than zero" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let quantity = match member "quantity" j with `Int i -> i | _ -> 0 in
  let foil = match member "foil" j with `Bool b -> b | _ -> false in
  let condition = match member "condition" j with `String s -> s | _ -> "" in
  let acquired_at = match member "acquired_at" j with `String s -> s | _ -> "" in
  let acquired_via = match member "acquired_via" j with `String s -> s | _ -> "" in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  ((quantity, foil, condition, acquired_at), (acquired_via, player_id, card_id))

let handler_player_collection (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/player_collections - list all *)
  | `GET, ["api"; "player_collections"] ->
    let* rows = Db.collect_list Player_collection_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Player_collection_model.to_yojson (Player_collection_model.row_to_t r) in
         apply_projection_player_collection j) items) in
       respond_json 200 json)

  (* POST /api/player_collections - create *)
  | `POST, ["api"; "player_collections"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_player_collection j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Player_collection_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Player_collection_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Player_collection_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Player_collection_model.to_yojson (Player_collection_model.row_to_t r) in
                respond_json 201 (apply_projection_player_collection j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/player_collections/:id - get one *)
  | `GET, ["api"; "player_collections"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Player_collection_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Player_collection_model.to_yojson (Player_collection_model.row_to_t r) in
          respond_json 200 (apply_projection_player_collection j)))

  (* PATCH /api/player_collections/:id - partial update *)
  | `PATCH, ["api"; "player_collections"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          let params = extract_insert_params j in
          let ((quantity, foil, condition, acquired_at), (acquired_via, player_id, card_id)) = params in
          let upd_params = ((quantity, foil, condition, acquired_at), (acquired_via, player_id, card_id, id)) in
          let* upd = Db.exec Player_collection_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Player_collection_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Player_collection_model.to_yojson (Player_collection_model.row_to_t r) in
                respond_json 200 (apply_projection_player_collection j)))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* DELETE /api/player_collections/:id *)
  | `DELETE, ["api"; "player_collections"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Player_collection_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* POST /api/collection/{id}/add - behavior add *)
  | `POST, ["api"; "player_collections"; id_str; "_id/add"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior add *)
       respond_json 204 (`Null))

  (* POST /api/collection/{id}/remove - behavior remove *)
  | `POST, ["api"; "player_collections"; id_str; "_id/remove"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior remove *)
       respond_json 204 (`Null))

  (* GET /api/collection/{id}/value - behavior estimated_value *)
  | `GET, ["api"; "player_collections"; id_str; "_id/value"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior estimated_value *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
