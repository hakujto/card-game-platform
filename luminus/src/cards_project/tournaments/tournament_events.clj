(ns cards_project.tournaments.tournament-events)

(defrecord TournamentCompleted [tournament_id season_id completed_at])

(defrecord PlayerRegistered [tournament_id player_id registered_at])
