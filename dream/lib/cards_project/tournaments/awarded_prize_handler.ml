(* Dream handlers for AwardedPrize *)
open Lwt.Syntax

let apply_projection_awarded_prize (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "awarded_at" then ("awarded_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "claimed_at" then ("claimed_at", v) else (k, v)) fields in
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

let validate_awarded_prize (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "final_placement") with Some v -> v > 0. | None -> true)) then errors := "Final placement must be greater than zero" :: !errors;
  if not ((not ((json_bool_opt j "claimed") = Some true) || ((json_present j "claimed_at")))) then errors := "Claimed prize must have a claimed_at timestamp" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let final_placement = match member "final_placement" j with `Int i -> i | _ -> 0 in
  let awarded_at = match member "awarded_at" j with `String s -> s | _ -> "" in
  let claimed = match member "claimed" j with `Bool b -> b | _ -> false in
  let claimed_at = match member "claimed_at" j with `String s -> Some s | _ -> None in
  let prize_id = match member "prize_id" j with `Int i -> i | _ -> 0 in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  ((final_placement, awarded_at, claimed, claimed_at), (prize_id, player_id))

let handler_awarded_prize (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/awarded_prizes - list all *)
  | `GET, ["api"; "awarded_prizes"] ->
    let* rows = Db.collect_list Awarded_prize_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Awarded_prize_model.to_yojson (Awarded_prize_model.row_to_t r) in
         apply_projection_awarded_prize j) items) in
       respond_json 200 json)

  (* GET /api/awarded_prizes/:id - get one *)
  | `GET, ["api"; "awarded_prizes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Awarded_prize_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Awarded_prize_model.to_yojson (Awarded_prize_model.row_to_t r) in
          respond_json 200 (apply_projection_awarded_prize j)))

  (* POST /api/awarded-prizes/{id}/claim - behavior claim *)
  | `POST, ["api"; "awarded_prizes"; id_str; "_id/claim"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior claim *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
