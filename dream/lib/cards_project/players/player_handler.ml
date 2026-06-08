(* Dream handlers for Player *)
open Lwt.Syntax

let apply_projection_player (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "last_active_at" then ("last_active_at", v) else (k, v)) fields in
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

let validate_player (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "rating") with Some v -> v >= 0. && v <= 9999. | None -> true)) then errors := "Rating must be between 0 and 9999" :: !errors;
  if not ((match (json_float_opt j "peak_rating") with Some v -> v >= (Option.value (json_float_opt j "rating") ~default:0.) | None -> true)) then errors := "Peak rating must be greater than or equal to current rating" :: !errors;
  if not ((json_present j "display_name")) then errors := "Display name must not be empty" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let display_name = match member "display_name" j with `String s -> s | _ -> "" in
  let rank = match member "rank" j with `String s -> s | _ -> "" in
  let rating = match member "rating" j with `Int i -> i | _ -> 0 in
  let peak_rating = match member "peak_rating" j with `Int i -> i | _ -> 0 in
  let bio = match member "bio" j with `String s -> Some s | _ -> None in
  let country_code = match member "country_code" j with `String s -> Some s | _ -> None in
  let avatar_url = match member "avatar_url" j with `String s -> Some s | _ -> None in
  let preferred_format = match member "preferred_format" j with `String s -> Some s | _ -> None in
  let is_verified = match member "is_verified" j with `Bool b -> b | _ -> false in
  let last_active_at = match member "last_active_at" j with `String s -> Some s | _ -> None in
  let user_id = match member "user_id" j with `Int i -> Some i | _ -> None in
  ((display_name, rank, rating, peak_rating), (bio, country_code, avatar_url, preferred_format), (is_verified, last_active_at, user_id))

let handler_player (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/players - list with optional ?q= search *)
  | `GET, ["api"; "players"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Player_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Player_model.row_to_t r).display_name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Player_model.to_yojson (Player_model.row_to_t r) in
         apply_projection_player j) filtered) in
       respond_json 200 json)

  (* POST /api/players - create *)
  | `POST, ["api"; "players"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_player j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Player_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Player_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Player_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Player_model.to_yojson (Player_model.row_to_t r) in
                respond_json 201 (apply_projection_player j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/players/:id - get one *)
  | `GET, ["api"; "players"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Player_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Player_model.to_yojson (Player_model.row_to_t r) in
          respond_json 200 (apply_projection_player j)))

  (* PATCH /api/players/:id - partial update *)
  | `PATCH, ["api"; "players"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          let params = extract_insert_params j in
          let ((display_name, rank, rating, peak_rating), (bio, country_code, avatar_url, preferred_format), (is_verified, last_active_at, user_id)) = params in
          let upd_params = ((display_name, rank, rating, peak_rating), (bio, country_code, avatar_url, preferred_format), (is_verified, last_active_at, user_id, id)) in
          let* upd = Db.exec Player_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Player_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Player_model.to_yojson (Player_model.row_to_t r) in
                respond_json 200 (apply_projection_player j)))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* POST /api/players/{id}/promote - behavior promote *)
  | `POST, ["api"; "players"; id_str; "_id/promote"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior promote *)
       respond_json 204 (`Null))

  (* POST /api/players/{id}/demote - behavior demote *)
  | `POST, ["api"; "players"; id_str; "_id/demote"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior demote *)
       respond_json 204 (`Null))

  (* POST /api/players/{id}/win - behavior record_win *)
  | `POST, ["api"; "players"; id_str; "_id/win"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior record_win *)
       respond_json 204 (`Null))

  (* POST /api/players/{id}/loss - behavior record_loss *)
  | `POST, ["api"; "players"; id_str; "_id/loss"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior record_loss *)
       respond_json 204 (`Null))

  (* GET /api/players/{id}/win-rate - behavior win_rate *)
  | `GET, ["api"; "players"; id_str; "_id/win-rate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior win_rate *)
       respond_json 204 (`Null))

  (* POST /api/players/{id}/verify - behavior verify *)
  | `POST, ["api"; "players"; id_str; "_id/verify"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior verify *)
       respond_json 204 (`Null))

  (* PATCH /api/players/{id}/rating - behavior update_rating *)
  | `PATCH, ["api"; "players"; id_str; "_id/rating"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior update_rating *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
