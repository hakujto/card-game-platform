package model_tournaments

// Domain events emitted by Tournament.
type TournamentTournamentCompletedEvent struct {
	TournamentId int `json:"tournament_id"`
	SeasonId int `json:"season_id"`
	CompletedAt string `json:"completed_at"`
}

type TournamentPlayerRegisteredEvent struct {
	TournamentId int `json:"tournament_id"`
	PlayerId int `json:"player_id"`
	RegisteredAt string `json:"registered_at"`
}
