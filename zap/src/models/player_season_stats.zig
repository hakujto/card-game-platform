const std = @import("std");

pub const PlayerSeasonStatsHighestRank = enum {
    bronze,
    silver,
    gold,
    platinum,
    diamond,
    master,
    grandmaster,
};

pub const PlayerSeasonStats = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    wins: i64 = 0,
    losses: i64 = 0,
    draws: i64 = 0,
    tournament_wins: i64 = 0,
    highest_rank: ?PlayerSeasonStatsHighestRank = null,
    season_points: i64 = 0,
    player_id: i64 = 0,
    season_id: i64 = 0,
};

pub const PlayerSeasonStatsCreateRequest = struct {
    wins: i64 = 0,
    losses: i64 = 0,
    draws: i64 = 0,
    tournament_wins: i64 = 0,
    highest_rank: ?PlayerSeasonStatsHighestRank = null,
    season_points: i64 = 0,
    player_id: i64 = 0,
    season_id: i64 = 0,
};

pub const PlayerSeasonStatsUpdateRequest = struct {
    wins: ?i64 = null,
    losses: ?i64 = null,
    draws: ?i64 = null,
    tournament_wins: ?i64 = null,
    highest_rank: ?PlayerSeasonStatsHighestRank = null,
    season_points: ?i64 = null,
    player_id: ?i64 = null,
    season_id: ?i64 = null,
};

pub const PlayerSeasonStatsResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    wins: i64,
    losses: i64,
    draws: i64,
    tournament_wins: i64,
    highest_rank: ?PlayerSeasonStatsHighestRank,
    season_points: i64,
    player_id: i64,
    season_id: i64,
};
