(* Domain events for TradeTransaction *)

type transaction_completed_t = {
  transaction_id : int;
  buyer_id : int;
  seller_id : int;
  final_price : float;
  completed_at : string;
} [@@deriving yojson]
