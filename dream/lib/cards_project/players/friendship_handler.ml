(* Dream handlers for Friendship *)
open Lwt.Syntax

let apply_projection_friendship (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    `Assoc fields
  | other -> other

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let requester_id = match member "requester_id" j with `Int i -> i | _ -> 0 in
  let receiver_id = match member "receiver_id" j with `Int i -> i | _ -> 0 in
  (status, requester_id, receiver_id)

let handler_friendship (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/friendships - list all *)
  | `GET, ["api"; "friendships"] ->
    let* rows = Db.collect_list Friendship_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Friendship_model.to_yojson (Friendship_model.row_to_t r) in
         apply_projection_friendship j) items) in
       respond_json 200 json)

  (* POST /api/friendships - create *)
  | `POST, ["api"; "friendships"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       let params = extract_insert_params j in
       let* ins = Db.exec Friendship_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Friendship_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Friendship_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Friendship_model.to_yojson (Friendship_model.row_to_t r) in
                respond_json 201 (apply_projection_friendship j)
              | Ok None -> respond_json 404 (`String "Not found"))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/friendships/:id - get one *)
  | `GET, ["api"; "friendships"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Friendship_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Friendship_model.to_yojson (Friendship_model.row_to_t r) in
          respond_json 200 (apply_projection_friendship j)))

  (* DELETE /api/friendships/:id *)
  | `DELETE, ["api"; "friendships"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Friendship_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* POST /api/friendships/{id}/accept - behavior accept *)
  | `POST, ["api"; "friendships"; id_str; "_id/accept"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior accept *)
       respond_json 204 (`Null))

  (* POST /api/friendships/{id}/decline - behavior decline *)
  | `POST, ["api"; "friendships"; id_str; "_id/decline"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior decline *)
       respond_json 204 (`Null))

  (* POST /api/friendships/{id}/block - behavior block *)
  | `POST, ["api"; "friendships"; id_str; "_id/block"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior block *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
