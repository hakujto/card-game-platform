(* Domain events for Tournament *)

type tournament_completed_t = {
  tournament_id : int;
  season_id : int;
  completed_at : string;
} [@@deriving yojson]

type player_registered_t = {
  tournament_id : int;
  player_id : int;
  registered_at : string;
} [@@deriving yojson]
