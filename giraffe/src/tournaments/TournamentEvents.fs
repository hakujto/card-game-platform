module cards_project.tournaments.TournamentEvents

// Domain events for Tournament

[<CLIMutable>]
type TournamentCompleted = {
    tournament_id: int
    season_id: int
    completed_at: string
}

[<CLIMutable>]
type PlayerRegistered = {
    tournament_id: int
    player_id: int
    registered_at: string
}
