(* Dream handlers for Card *)
open Lwt.Syntax

(* ── Lifecycle hooks ─────────────────────────────────────────────────── *)
let hook_validate_legality () =
  (* TODO: implement validate_legality *)
  ()

let hook_validate_not_in_use () =
  (* TODO: implement validate_not_in_use *)
  ()

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

let validate_card (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "mana_cost") with Some v -> v >= 0. && v <= 20. | None -> true)) then errors := "mana_cost must be between 0 and 20" :: !errors;
  if not ((match (json_float_opt j "power_level") with Some v -> v >= 1. && v <= 10. | None -> true)) then errors := "power_level must be between 1 and 10" :: !errors;
  if not (not (((json_bool_opt j "is_banned") = Some true && (json_bool_opt j "is_restricted") = Some true))) then errors := "Card cannot be both banned and restricted at the same time" :: !errors;
  if not ((not ((json_string_opt j "card_type") = Some "Creature") || ((json_present j "attack") && (json_present j "defense")))) then errors := "Creature card must have attack and defense" :: !errors;
  if not ((not ((json_string_opt j "card_type") = Some "Planeswalker") || ((json_present j "loyalty")))) then errors := "Planeswalker card must have loyalty" :: !errors;
  if not ((not ((json_string_opt j "card_type") = Some "Land") || ((json_float_opt j "mana_cost") = Some 0.))) then errors := "Land card must have zero mana cost" :: !errors;
  if not ((not ((json_string_opt j "card_type") <> Some "Planeswalker") || ((not (json_present j "loyalty"))))) then errors := "Only Planeswalker cards can have loyalty" :: !errors;
  if not ((not ((json_bool_opt j "is_banned") = Some true) || ((json_string_opt j "legal_formats") = Some "message"))) then errors := "banned_card_not_in_legal_formats" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let card_type = match member "card_type" j with `String s -> s | _ -> "" in
  let rarity = match member "rarity" j with `String s -> s | _ -> "" in
  let mana_cost = match member "mana_cost" j with `Int i -> i | _ -> 0 in
  let mana_colors = match member "mana_colors" j with `String s -> s | _ -> "" in
  let attack = match member "attack" j with `Int i -> Some i | _ -> None in
  let defense = match member "defense" j with `Int i -> Some i | _ -> None in
  let loyalty = match member "loyalty" j with `Int i -> Some i | _ -> None in
  let description = match member "description" j with `String s -> s | _ -> "" in
  let flavor_text = match member "flavor_text" j with `String s -> Some s | _ -> None in
  let image_url = match member "image_url" j with `String s -> Some s | _ -> None in
  let artist_name = match member "artist_name" j with `String s -> Some s | _ -> None in
  let legal_formats = match member "legal_formats" j with `String s -> s | _ -> "" in
  let is_banned = match member "is_banned" j with `Bool b -> b | _ -> false in
  let is_restricted = match member "is_restricted" j with `Bool b -> b | _ -> false in
  let power_level = match member "power_level" j with `Int i -> i | _ -> 0 in
  let set_id = match member "set_id" j with `Int i -> i | _ -> 0 in
  (((name, card_type, rarity, mana_cost), (mana_colors, attack, defense, loyalty), (description, flavor_text, image_url, artist_name), (legal_formats, is_banned, is_restricted, power_level)), set_id)

let handler_card (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/cards - list with optional ?q= search *)
  | `GET, ["api"; "cards"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Card_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Card_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)
           || (match (Card_model.row_to_t r).artist_name with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Card_model.to_yojson (Card_model.row_to_t r) in
         j) filtered) in
       respond_json 200 json)

  (* POST /api/cards - create *)
  | `POST, ["api"; "cards"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_card j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Card_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Card_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Card_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Card_model.to_yojson (Card_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/cards/:id - get one *)
  | `GET, ["api"; "cards"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Card_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Card_model.to_yojson (Card_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/cards/:id - full update *)
  | `PUT, ["api"; "cards"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_card j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let (((name, card_type, rarity, mana_cost), (mana_colors, attack, defense, loyalty), (description, flavor_text, image_url, artist_name), (legal_formats, is_banned, is_restricted, power_level)), set_id) = params in
          let upd_params = (((name, card_type, rarity, mana_cost), (mana_colors, attack, defense, loyalty), (description, flavor_text, image_url, artist_name), (legal_formats, is_banned, is_restricted, power_level)), (set_id, id)) in
          let* upd = Db.exec Card_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Card_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Card_model.to_yojson (Card_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* POST /api/cards/{id}/ban - behavior ban *)
  | `POST, ["api"; "cards"; id_str; "_id/ban"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior ban *)
       respond_json 204 (`Null))

  (* POST /api/cards/{id}/unban - behavior unban *)
  | `POST, ["api"; "cards"; id_str; "_id/unban"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior unban *)
       respond_json 204 (`Null))

  (* POST /api/cards/{id}/restrict - behavior restrict *)
  | `POST, ["api"; "cards"; id_str; "_id/restrict"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior restrict *)
       respond_json 204 (`Null))

  (* POST /api/cards/{id}/unrestrict - behavior unrestrict *)
  | `POST, ["api"; "cards"; id_str; "_id/unrestrict"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior unrestrict *)
       respond_json 204 (`Null))

  (* GET /api/cards/{id}/value - behavior calculate_value *)
  | `GET, ["api"; "cards"; id_str; "_id/value"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior calculate_value *)
       respond_json 204 (`Null))

  (* POST /api/cards/{id}/rarity-bonus - behavior apply_rarity_bonus *)
  | `POST, ["api"; "cards"; id_str; "_id/rarity-bonus"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior apply_rarity_bonus *)
       respond_json 204 (`Null))

  (* GET /api/cards/{id}/legal - behavior is_legal_in_format *)
  | `GET, ["api"; "cards"; id_str; "_id/legal"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_legal_in_format *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
