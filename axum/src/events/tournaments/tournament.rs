// src/events/tournaments/tournament.rs — domain events
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TournamentCompleted {
    pub tournament_id: i64,
    pub season_id: i64,
    pub completed_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerRegistered {
    pub tournament_id: i64,
    pub player_id: i64,
    pub registered_at: String,
}
