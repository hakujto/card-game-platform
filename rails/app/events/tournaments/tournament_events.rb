module Events
  module Tournaments
    TournamentCompleted = Struct.new(
      :tournament_id, :season_id, :completed_at,
      keyword_init: true
    )
    PlayerRegistered = Struct.new(
      :tournament_id, :player_id, :registered_at,
      keyword_init: true
    )
  end
end