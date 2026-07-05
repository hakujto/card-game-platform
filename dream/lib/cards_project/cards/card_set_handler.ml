(* Dream handlers for CardSet *)
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

let validate_card_set (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "total_cards") with Some v -> v > 0. | None -> true)) then errors := "Card set must have at least one card" :: !errors;
  if not ((not ((json_present j "rotation_date")) || ((match (json_float_opt j "rotation_date") with Some v -> v > (Option.value (json_float_opt j "release_date") ~default:0.) | None -> true)))) then errors := "Rotation date must be after release date" :: !errors;
  if not ((not ((json_bool_opt j "is_rotated") = Some true) || ((json_present j "rotation_date")))) then errors := "Rotated set must have a rotation date" :: !errors;
  (match json_string_opt j "code" with
   | Some v when not (Re.execp (Re.compile (Re.Perl.re ~opts:[`Anchored] "[A-Z]{2,6}")) v) ->
     errors := "code: invalid format" :: !errors
   | _ -> ());
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let code = match member "code" j with `String s -> s | _ -> "" in
  let release_date = match member "release_date" j with `String s -> s | _ -> "" in
  let rotation_date = match member "rotation_date" j with `String s -> Some s | _ -> None in
  let set_type = match member "set_type" j with `String s -> s | _ -> "" in
  let total_cards = match member "total_cards" j with `Int i -> i | _ -> 0 in
  let is_rotated = match member "is_rotated" j with `Bool b -> b | _ -> false in
  let description = match member "description" j with `String s -> Some s | _ -> None in
  let logo_url = match member "logo_url" j with `String s -> Some s | _ -> None in
  ((name, code, release_date, rotation_date), (set_type, total_cards, is_rotated, description), logo_url)

let handler_card_set (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/card_sets - list with optional ?q= search *)
  | `GET, ["api"; "card_sets"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Card_set_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Card_set_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)
           || let s = (Card_set_model.row_to_t r).code in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Card_set_model.to_yojson (Card_set_model.row_to_t r) in
         j) filtered) in
       respond_json 200 json)

  (* POST /api/card_sets - create *)
  | `POST, ["api"; "card_sets"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_card_set j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Card_set_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Card_set_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Card_set_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Card_set_model.to_yojson (Card_set_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/card_sets/:id - get one *)
  | `GET, ["api"; "card_sets"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Card_set_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Card_set_model.to_yojson (Card_set_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/card_sets/:id - full update *)
  | `PUT, ["api"; "card_sets"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_card_set j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((name, code, release_date, rotation_date), (set_type, total_cards, is_rotated, description), logo_url) = params in
          let upd_params = ((name, code, release_date, rotation_date), (set_type, total_cards, is_rotated, description), (logo_url, id)) in
          let* upd = Db.exec Card_set_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Card_set_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Card_set_model.to_yojson (Card_set_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* GET /api/card-sets/{id}/standard-legal - behavior is_legal_in_standard *)
  | `GET, ["api"; "card_sets"; id_str; "_id/standard-legal"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_legal_in_standard *)
       respond_json 204 (`Null))

  (* GET /api/card-sets/{id}/legal - behavior is_legal_in_format *)
  | `GET, ["api"; "card_sets"; id_str; "_id/legal"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_legal_in_format *)
       respond_json 204 (`Null))

  (* GET /api/card-sets/{id}/rarity-count - behavior card_count_by_rarity *)
  | `GET, ["api"; "card_sets"; id_str; "_id/rarity-count"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior card_count_by_rarity *)
       respond_json 204 (`Null))

  (* POST /api/card-sets/{id}/rotate - behavior rotate_out *)
  | `POST, ["api"; "card_sets"; id_str; "_id/rotate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior rotate_out *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
