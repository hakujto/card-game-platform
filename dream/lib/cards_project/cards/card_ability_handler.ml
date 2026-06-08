(* Dream handlers for CardAbility *)
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

let validate_card_ability (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((not ((json_string_opt j "ability_type") = Some "Keyword") || ((json_present j "keyword")))) then errors := "Keyword ability must have a keyword name" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let ability_type = match member "ability_type" j with `String s -> s | _ -> "" in
  let keyword = match member "keyword" j with `String s -> Some s | _ -> None in
  let ability_text = match member "ability_text" j with `String s -> s | _ -> "" in
  let timing = match member "timing" j with `String s -> Some s | _ -> None in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  ((ability_type, keyword, ability_text, timing), card_id)

let handler_card_ability (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/card_abilities - list with optional ?q= search *)
  | `GET, ["api"; "card_abilities"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Card_ability_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           (match (Card_ability_model.row_to_t r).keyword with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)
           || let s = (Card_ability_model.row_to_t r).ability_text in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Card_ability_model.to_yojson (Card_ability_model.row_to_t r) in
         j) filtered) in
       respond_json 200 json)

  (* POST /api/card_abilities - create *)
  | `POST, ["api"; "card_abilities"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_card_ability j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Card_ability_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Card_ability_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Card_ability_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Card_ability_model.to_yojson (Card_ability_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/card_abilities/:id - get one *)
  | `GET, ["api"; "card_abilities"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Card_ability_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Card_ability_model.to_yojson (Card_ability_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/card_abilities/:id - full update *)
  | `PUT, ["api"; "card_abilities"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_card_ability j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((ability_type, keyword, ability_text, timing), card_id) = params in
          let upd_params = ((ability_type, keyword, ability_text, timing), (card_id, id)) in
          let* upd = Db.exec Card_ability_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Card_ability_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Card_ability_model.to_yojson (Card_ability_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* DELETE /api/card_abilities/:id *)
  | `DELETE, ["api"; "card_abilities"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Card_ability_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* GET /api/card-abilities/{id}/usable - behavior is_usable_at *)
  | `GET, ["api"; "card_abilities"; id_str; "_id/usable"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_usable_at *)
       respond_json 204 (`Null))

  (* GET /api/card-abilities/{id}/describe - behavior describe *)
  | `GET, ["api"; "card_abilities"; id_str; "_id/describe"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior describe *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
