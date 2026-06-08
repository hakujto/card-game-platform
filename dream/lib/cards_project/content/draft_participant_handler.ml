(* Dream handlers for DraftParticipant *)
open Lwt.Syntax

let apply_projection_draft_participant (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "joined_at" then ("joined_at", v) else (k, v)) fields in
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

let validate_draft_participant (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "seat_number") with Some v -> v > 0. | None -> true)) then errors := "Seat number must be greater than zero" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let seat_number = match member "seat_number" j with `Int i -> i | _ -> 0 in
  let joined_at = match member "joined_at" j with `String s -> s | _ -> "" in
  let session_id = match member "session_id" j with `Int i -> i | _ -> 0 in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  (seat_number, joined_at, session_id, player_id)

let handler_draft_participant (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/draft_participants - list all *)
  | `GET, ["api"; "draft_participants"] ->
    let* rows = Db.collect_list Draft_participant_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Draft_participant_model.to_yojson (Draft_participant_model.row_to_t r) in
         apply_projection_draft_participant j) items) in
       respond_json 200 json)

  (* POST /api/draft_participants - create *)
  | `POST, ["api"; "draft_participants"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_draft_participant j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Draft_participant_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Draft_participant_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Draft_participant_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Draft_participant_model.to_yojson (Draft_participant_model.row_to_t r) in
                respond_json 201 (apply_projection_draft_participant j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/draft_participants/:id - get one *)
  | `GET, ["api"; "draft_participants"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_participant_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Draft_participant_model.to_yojson (Draft_participant_model.row_to_t r) in
          respond_json 200 (apply_projection_draft_participant j)))

  (* POST /api/draft-participants/{id}/pick - behavior pick_card *)
  | `POST, ["api"; "draft_participants"; id_str; "_id/pick"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior pick_card *)
       respond_json 204 (`Null))

  (* GET /api/draft-participants/{id}/card-count - behavior drafted_card_count *)
  | `GET, ["api"; "draft_participants"; id_str; "_id/card-count"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior drafted_card_count *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
