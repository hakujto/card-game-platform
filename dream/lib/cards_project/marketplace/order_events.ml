(* Domain events for Order *)

type order_paid_t = {
  order_id : int;
  player_id : int;
  total : float;
  payment_method : string;
  paid_at : string;
} [@@deriving yojson]

type order_shipped_t = {
  order_id : int;
  tracking_number : string;
  shipped_at : string;
} [@@deriving yojson]

type order_refunded_t = {
  order_id : int;
  refunded_at : string;
} [@@deriving yojson]
