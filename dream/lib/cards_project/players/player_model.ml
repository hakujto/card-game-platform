(* Player model — record type + Caqti query definitions *)

type t = {
  id : int;
  public_id : string;
  display_name : string;
  rank : string;
  rating : int;
  peak_rating : int;
  bio : string option;
  country_code : string option;
  avatar_url : string option;
  preferred_format : string option;
  contact_email : string option;
  win_rate_cached : float option;
  is_verified : bool;
  last_active_at : string option;
  user_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Player:
 *   has_many decks -> Deck via player_id
 *   has_many season_stats -> PlayerSeasonStats via player_id
 *   has_many collection -> PlayerCollection via player_id
 *   has_many sent_friend_requests -> Friendship via requester_id
 *   has_many received_friend_requests -> Friendship via receiver_id
 *   has_many achievement_records -> PlayerAchievement via player_id
 *   has_many organized_tournaments -> Tournament via organizer_id
 *   many_to_many judged_tournaments -> Tournament through tournament_judges
 *   has_many judge_roles -> TournamentJudge via player_id
 *   has_many tournament_registrations -> TournamentRegistration via player_id
 *   has_many matches_as_player1 -> Match via player1_id
 *   has_many matches_as_player2 -> Match via player2_id
 *   has_many won_games -> Game via winner_id
 *   has_many awarded_prizes -> AwardedPrize via player_id
 *   has_many orders -> Order via player_id
 *   has_many trade_listings -> TradeListing via seller_id
 *   has_many bids -> TradeBid via bidder_id
 *   has_many purchases -> TradeTransaction via buyer_id
 *   has_many sales -> TradeTransaction via seller_id
 *   has_many disputes_opened -> TradeDispute via opened_by_id
 *   has_many disputes_resolved -> TradeDispute via resolved_by_id
 *   has_many draft_sessions -> DraftParticipant via player_id
 *   has_many articles -> Article via author_id
 *   has_many article_comments -> ArticleComment via author_id
 *   has_many streams -> Stream via streamer_id
 *)

(* ── Caqti query definitions for Player ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Player record *)
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), v16) : t = {
  id = v0;
  public_id = v1;
  display_name = v2;
  rank = v3;
  rating = v4;
  peak_rating = v5;
  bio = v6;
  country_code = v7;
  avatar_url = v8;
  preferred_format = v9;
  contact_email = v10;
  win_rate_cached = v11;
  is_verified = v12;
  last_active_at = v13;
  user_id = v14;
  created_at = v15;
  updated_at = v16;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string string string) (t4 int int (option string) (option string)) (t4 (option string) (option string) (option string) (option float)) (t4 bool (option string) (option int) string)) string) @@
  {sql| SELECT id, public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id, created_at, updated_at FROM players ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string string string) (t4 int int (option string) (option string)) (t4 (option string) (option string) (option string) (option float)) (t4 bool (option string) (option int) string)) string) @@
  {sql| SELECT id, public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id, created_at, updated_at FROM players WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 (t4 string string string int) (t4 int (option string) (option string) (option string)) (t4 (option string) (option string) (option float) bool) (t2 (option string) (option int))) ->. Caqti_type.unit @@
  {sql| INSERT INTO players (public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 (t4 string string string (option string)) (t4 (option string) (option string) (option string) (option string)) (t4 (option float) bool (option string) (option int)) int) ->. Caqti_type.unit @@
  {sql| UPDATE players SET public_id = ?, display_name = ?, rank = ?, bio = ?, country_code = ?, avatar_url = ?, preferred_format = ?, contact_email = ?, win_rate_cached = ?, is_verified = ?, last_active_at = ?, user_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM players WHERE id = ? |sql}
