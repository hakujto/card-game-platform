const std = @import("std");

pub const TournamentPrizePrizeType = enum {
    currency,
    cards,
    booster_packs,
    trophy,
    season_points,
    mixed,
};

pub const TournamentPrize = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    placement_from: i64 = 0,
    placement_to: i64 = 0,
    prize_type: TournamentPrizePrizeType = .currency,
    amount: f64 = 0,
    description: ?[]const u8 = null,
    packs_count: ?i64 = null,
    season_points: i64 = 0,
    tournament_id: i64 = 0,
};

pub const TournamentPrizeCreateRequest = struct {
    placement_from: i64 = 0,
    placement_to: i64 = 0,
    prize_type: TournamentPrizePrizeType = .currency,
    amount: f64 = 0,
    description: ?[]const u8 = null,
    packs_count: ?i64 = null,
    season_points: i64 = 0,
    tournament_id: i64 = 0,
};

pub const TournamentPrizeUpdateRequest = struct {
    placement_from: ?i64 = null,
    placement_to: ?i64 = null,
    prize_type: ?TournamentPrizePrizeType = null,
    amount: ?f64 = null,
    description: ?[]const u8 = null,
    packs_count: ?i64 = null,
    season_points: ?i64 = null,
    tournament_id: ?i64 = null,
};

pub const TournamentPrizeResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    placement_from: i64,
    placement_to: i64,
    prize_type: TournamentPrizePrizeType,
    amount: f64,
    description: ?[]const u8,
    packs_count: ?i64,
    season_points: i64,
    tournament_id: i64,
};
