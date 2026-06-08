(* Dream handlers for DraftPick *)
open Lwt.Syntax

let apply_projection_draft_pick (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "picked_at" then ("picked_at", v) else (k, v)) fields in
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

let validate_draft_pick (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "pick_number") with Some v -> v > 0. | None -> true)) then errors := "Pick number must be greater than zero" :: !errors;
  if not ((match (json_float_opt j "pack_number") with Some v -> v >= 1. && v <= 3. | None -> true)) then errors := "Pack number must be between 1 and 3" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let pick_number = match member "pick_number" j with `Int i -> i | _ -> 0 in
  let pack_number = match member "pack_number" j with `Int i -> i | _ -> 0 in
  let picked_at = match member "picked_at" j with `String s -> s | _ -> "" in
  let participant_id = match member "participant_id" j with `Int i -> i | _ -> 0 in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  ((pick_number, pack_number, picked_at, participant_id), card_id)

let handler_draft_pick (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/draft_picks - list all *)
  | `GET, ["api"; "draft_picks"] ->
    let* rows = Db.collect_list Draft_pick_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Draft_pick_model.to_yojson (Draft_pick_model.row_to_t r) in
         apply_projection_draft_pick j) items) in
       respond_json 200 json)

  (* GET /api/draft_picks/:id - get one *)
  | `GET, ["api"; "draft_picks"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_pick_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Draft_pick_model.to_yojson (Draft_pick_model.row_to_t r) in
          respond_json 200 (apply_projection_draft_pick j)))

  (* GET /api/draft-picks/{id}/first-pick - behavior is_first_pick *)
  | `GET, ["api"; "draft_picks"; id_str; "_id/first-pick"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_first_pick *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
