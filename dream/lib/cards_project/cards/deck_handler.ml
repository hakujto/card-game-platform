(* Dream handlers for Deck *)
open Lwt.Syntax

(* ── Lifecycle hooks ─────────────────────────────────────────────────── *)
let hook_recalculate_tournament_legal () =
  (* TODO: implement recalculate_tournament_legal *)
  ()

let apply_projection_deck (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "updated_at" then ("updated_at", v) else (k, v)) fields in
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

let validate_deck (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "wins") with Some v -> v >= 0. | None -> true)) then errors := "Deck wins count must not be negative" :: !errors;
  if not ((match (json_float_opt j "losses") with Some v -> v >= 0. | None -> true)) then errors := "Deck losses count must not be negative" :: !errors;
  if not ((match (json_float_opt j "draws") with Some v -> v >= 0. | None -> true)) then errors := "Deck draws count must not be negative" :: !errors;
  if not ((not ((json_bool_opt j "is_tournament_legal") = Some true) || ((json_bool_opt j "is_public") = Some true))) then errors := "Tournament-legal deck must be made public" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let description = match member "description" j with `String s -> Some s | _ -> None in
  let format = match member "format" j with `String s -> s | _ -> "" in
  let is_public = match member "is_public" j with `Bool b -> b | _ -> false in
  let is_tournament_legal = match member "is_tournament_legal" j with `Bool b -> b | _ -> false in
  let archetype = match member "archetype" j with `String s -> Some s | _ -> None in
  let wins = match member "wins" j with `Int i -> i | _ -> 0 in
  let losses = match member "losses" j with `Int i -> i | _ -> 0 in
  let draws = match member "draws" j with `Int i -> i | _ -> 0 in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  ((name, description, format, is_public), (is_tournament_legal, archetype, wins, losses), (draws, player_id))

let handler_deck (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/decks - list with optional ?q= search *)
  | `GET, ["api"; "decks"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Deck_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Deck_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)
           || (match (Deck_model.row_to_t r).description with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Deck_model.to_yojson (Deck_model.row_to_t r) in
         apply_projection_deck j) filtered) in
       respond_json 200 json)

  (* POST /api/decks - create *)
  | `POST, ["api"; "decks"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_deck j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Deck_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Deck_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Deck_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Deck_model.to_yojson (Deck_model.row_to_t r) in
                respond_json 201 (apply_projection_deck j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/decks/:id - get one *)
  | `GET, ["api"; "decks"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Deck_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Deck_model.to_yojson (Deck_model.row_to_t r) in
          respond_json 200 (apply_projection_deck j)))

  (* PUT /api/decks/:id - full update *)
  | `PUT, ["api"; "decks"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_deck j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((name, description, format, is_public), (is_tournament_legal, archetype, wins, losses), (draws, player_id)) = params in
          let upd_params = ((name, description, format, is_public), (is_tournament_legal, archetype, wins, losses), (draws, player_id, id)) in
          let* upd = Db.exec Deck_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Deck_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Deck_model.to_yojson (Deck_model.row_to_t r) in
                respond_json 200 (apply_projection_deck j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* DELETE /api/decks/:id *)
  | `DELETE, ["api"; "decks"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Deck_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* GET /api/decks/{id}/validate - behavior validate_size *)
  | `GET, ["api"; "decks"; id_str; "_id/validate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior validate_size *)
       respond_json 204 (`Null))

  (* POST /api/decks/{id}/cards - behavior add_card *)
  | `POST, ["api"; "decks"; id_str; "_id/cards"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior add_card *)
       respond_json 204 (`Null))

  (* DELETE /api/decks/{id}/cards/{card_id} - behavior remove_card *)
  | `GET, ["api"; "decks"; id_str; "_id/cards/_card_id"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior remove_card *)
       respond_json 204 (`Null))

  (* GET /api/decks/{id}/win-rate - behavior win_rate *)
  | `GET, ["api"; "decks"; id_str; "_id/win-rate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior win_rate *)
       respond_json 204 (`Null))

  (* POST /api/decks/{id}/clone - behavior clone *)
  | `POST, ["api"; "decks"; id_str; "_id/clone"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior clone *)
       respond_json 204 (`Null))

  (* POST /api/decks/{id}/publish - behavior publish *)
  | `POST, ["api"; "decks"; id_str; "_id/publish"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior publish *)
       respond_json 204 (`Null))

  (* POST /api/decks/{id}/unpublish - behavior unpublish *)
  | `POST, ["api"; "decks"; id_str; "_id/unpublish"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior unpublish *)
       respond_json 204 (`Null))

  (* POST /api/decks/{id}/certify - behavior certify_tournament_legal *)
  | `POST, ["api"; "decks"; id_str; "_id/certify"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior certify_tournament_legal *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
