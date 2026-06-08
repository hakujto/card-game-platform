(* Dream handlers for DeckCard *)
open Lwt.Syntax

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

let validate_deck_card (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "quantity") with Some v -> v >= 1. && v <= 4. | None -> true)) then errors := "A deck can contain between 1 and 4 copies of a card" :: !errors;
  if not ((not ((json_bool_opt j "is_commander") = Some true) || ((json_float_opt j "quantity") = Some 1.))) then errors := "Commander card must appear exactly once in the deck" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let quantity = match member "quantity" j with `Int i -> i | _ -> 0 in
  let is_commander = match member "is_commander" j with `Bool b -> b | _ -> false in
  let deck_id = match member "deck_id" j with `Int i -> i | _ -> 0 in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  (quantity, is_commander, deck_id, card_id)

let handler_deck_card (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/deck_cards - list all *)
  | `GET, ["api"; "deck_cards"] ->
    let* rows = Db.collect_list Deck_card_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Deck_card_model.to_yojson (Deck_card_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/deck_cards - create *)
  | `POST, ["api"; "deck_cards"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_deck_card j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Deck_card_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Deck_card_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Deck_card_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Deck_card_model.to_yojson (Deck_card_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/deck_cards/:id - get one *)
  | `GET, ["api"; "deck_cards"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Deck_card_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Deck_card_model.to_yojson (Deck_card_model.row_to_t r) in
          respond_json 200 (j)))

  (* PATCH /api/deck_cards/:id - partial update *)
  | `PATCH, ["api"; "deck_cards"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          let params = extract_insert_params j in
          let (quantity, is_commander, deck_id, card_id) = params in
          let upd_params = ((quantity, is_commander, deck_id, card_id), id) in
          let* upd = Db.exec Deck_card_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Deck_card_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Deck_card_model.to_yojson (Deck_card_model.row_to_t r) in
                respond_json 200 (j)))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* DELETE /api/deck_cards/:id *)
  | `DELETE, ["api"; "deck_cards"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Deck_card_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* PATCH /api/deck-cards/{id}/increment - behavior increment *)
  | `PATCH, ["api"; "deck_cards"; id_str; "_id/increment"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior increment *)
       respond_json 204 (`Null))

  (* PATCH /api/deck-cards/{id}/decrement - behavior decrement *)
  | `PATCH, ["api"; "deck_cards"; id_str; "_id/decrement"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior decrement *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
