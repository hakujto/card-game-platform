# src/events/tournaments/tournament.cr — domain events

struct TournamentCompleted
  property tournament_id : Int32
  property season_id : Int32
  property completed_at : String
end

struct PlayerRegistered
  property tournament_id : Int32
  property player_id : Int32
  property registered_at : String
end
