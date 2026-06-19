(* Dream handlers for TournamentRegistration *)
open Lwt.Syntax

let apply_projection_tournament_registration (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "registered_at" then ("registered_at", v) else (k, v)) fields in
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

let validate_tournament_registration (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "points_earned") with Some v -> v >= 0. | None -> true)) then errors := "Points earned must not be negative" :: !errors;
  if not ((not ((json_present j "final_standing")) || ((match (json_float_opt j "final_standing") with Some v -> v > 0. | None -> true)))) then errors := "Final standing must be greater than zero" :: !errors;
  if not ((not ((json_present j "seed")) || ((match (json_float_opt j "seed") with Some v -> v > 0. | None -> true)))) then errors := "Seed must be greater than zero" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let seed = match member "seed" j with `Int i -> Some i | _ -> None in
  let final_standing = match member "final_standing" j with `Int i -> Some i | _ -> None in
  let points_earned = match member "points_earned" j with `Int i -> i | _ -> 0 in
  let registered_at = match member "registered_at" j with `String s -> s | _ -> "" in
  let tournament_id = match member "tournament_id" j with `Int i -> i | _ -> 0 in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  let deck_id = match member "deck_id" j with `Int i -> i | _ -> 0 in
  ((status, seed, final_standing, points_earned), (registered_at, tournament_id, player_id, deck_id))

let handler_tournament_registration (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/tournament_registrations - list all *)
  | `GET, ["api"; "tournament_registrations"] ->
    let* rows = Db.collect_list Tournament_registration_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Tournament_registration_model.to_yojson (Tournament_registration_model.row_to_t r) in
         apply_projection_tournament_registration j) items) in
       respond_json 200 json)

  (* POST /api/tournament_registrations - create *)
  | `POST, ["api"; "tournament_registrations"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_tournament_registration j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Tournament_registration_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Tournament_registration_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Tournament_registration_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Tournament_registration_model.to_yojson (Tournament_registration_model.row_to_t r) in
                respond_json 201 (apply_projection_tournament_registration j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/tournament_registrations/:id - get one *)
  | `GET, ["api"; "tournament_registrations"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_registration_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Tournament_registration_model.row_to_t r in
          let owner_ok =
            match Dream.header req "X-User-Id" with
            | None -> false
            | Some uid_str ->
              (match int_of_string_opt uid_str with
               | None -> false
               | Some uid -> (rec_).player_id = uid)
          in
          if not owner_ok then respond_json 403 (`String "You do not own this resource.")
          else
          let j = Tournament_registration_model.to_yojson rec_ in
          respond_json 200 (apply_projection_tournament_registration j)))

  (* POST /api/registrations/{id}/withdraw - behavior withdraw *)
  | `POST, ["api"; "tournament_registrations"; id_str; "_id/withdraw"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior withdraw *)
       respond_json 204 (`Null))

  (* POST /api/registrations/{id}/disqualify - behavior disqualify *)
  | `POST, ["api"; "tournament_registrations"; id_str; "_id/disqualify"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior disqualify *)
       respond_json 204 (`Null))

  (* POST /api/registrations/{id}/promote - behavior promote_from_waitlist *)
  | `POST, ["api"; "tournament_registrations"; id_str; "_id/promote"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior promote_from_waitlist *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
