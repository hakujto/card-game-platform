// Domain events for tournaments

pub const TournamentCompleted = struct {
    tournament_id: i64,
    season_id: i64,
    completed_at: []const u8,
};

pub const PlayerRegistered = struct {
    tournament_id: i64,
    player_id: i64,
    registered_at: []const u8,
};
