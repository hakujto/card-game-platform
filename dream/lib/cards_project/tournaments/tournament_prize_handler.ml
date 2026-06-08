(* Dream handlers for TournamentPrize *)
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

let validate_tournament_prize (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "placement_to") with Some v -> v >= (Option.value (json_float_opt j "placement_from") ~default:0.) | None -> true)) then errors := "placement_to must be greater than or equal to placement_from" :: !errors;
  if not ((match (json_float_opt j "placement_from") with Some v -> v > 0. | None -> true)) then errors := "placement_from must be greater than zero" :: !errors;
  if not ((match (json_float_opt j "amount") with Some v -> v >= 0. | None -> true)) then errors := "Prize amount must not be negative" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let placement_from = match member "placement_from" j with `Int i -> i | _ -> 0 in
  let placement_to = match member "placement_to" j with `Int i -> i | _ -> 0 in
  let prize_type = match member "prize_type" j with `String s -> s | _ -> "" in
  let amount = match member "amount" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let description = match member "description" j with `String s -> Some s | _ -> None in
  let packs_count = match member "packs_count" j with `Int i -> Some i | _ -> None in
  let season_points = match member "season_points" j with `Int i -> i | _ -> 0 in
  let tournament_id = match member "tournament_id" j with `Int i -> i | _ -> 0 in
  ((placement_from, placement_to, prize_type, amount), (description, packs_count, season_points, tournament_id))

let handler_tournament_prize (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/tournament_prizes - list all *)
  | `GET, ["api"; "tournament_prizes"] ->
    let* rows = Db.collect_list Tournament_prize_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Tournament_prize_model.to_yojson (Tournament_prize_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/tournament_prizes - create *)
  | `POST, ["api"; "tournament_prizes"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_tournament_prize j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Tournament_prize_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Tournament_prize_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Tournament_prize_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Tournament_prize_model.to_yojson (Tournament_prize_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/tournament_prizes/:id - get one *)
  | `GET, ["api"; "tournament_prizes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_prize_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Tournament_prize_model.to_yojson (Tournament_prize_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/tournament_prizes/:id - full update *)
  | `PUT, ["api"; "tournament_prizes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_tournament_prize j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((placement_from, placement_to, prize_type, amount), (description, packs_count, season_points, tournament_id)) = params in
          let upd_params = ((placement_from, placement_to, prize_type, amount), (description, packs_count, season_points, tournament_id), id) in
          let* upd = Db.exec Tournament_prize_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Tournament_prize_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Tournament_prize_model.to_yojson (Tournament_prize_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* DELETE /api/tournament_prizes/:id *)
  | `DELETE, ["api"; "tournament_prizes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Tournament_prize_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* GET /api/prizes/{id}/applies - behavior applies_to_placement *)
  | `GET, ["api"; "tournament_prizes"; id_str; "_id/applies"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior applies_to_placement *)
       respond_json 204 (`Null))

  (* POST /api/prizes/{id}/award - behavior award_to_player *)
  | `POST, ["api"; "tournament_prizes"; id_str; "_id/award"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior award_to_player *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
