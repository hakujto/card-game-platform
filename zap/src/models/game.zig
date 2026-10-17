const std = @import("std");

pub const GameWinnerSide = enum {
    player1,
    player2,
    draw,
};

pub const GameEndedBy = enum {
    normal,
    timeout,
    concession,
    draw_offer,
};

pub const Game = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    game_number: i64 = 0,
    winner_side: ?GameWinnerSide = null,
    complexity_score: ?f64 = null,
    turns_played: ?i64 = null,
    duration_seconds: ?i64 = null,
    ended_by: ?GameEndedBy = null,
    replay_url: ?[]const u8 = null,
    match_id: i64 = 0,
    winner_id: ?i64 = null,
};

pub const GameCreateRequest = struct {
    game_number: i64 = 0,
    winner_side: ?GameWinnerSide = null,
    complexity_score: ?f64 = null,
    turns_played: ?i64 = null,
    duration_seconds: ?i64 = null,
    ended_by: ?GameEndedBy = null,
    replay_url: ?[]const u8 = null,
    match_id: i64 = 0,
    winner_id: ?i64 = null,
};

pub const GameUpdateRequest = struct {
    game_number: ?i64 = null,
    winner_side: ?GameWinnerSide = null,
    complexity_score: ?f64 = null,
    turns_played: ?i64 = null,
    duration_seconds: ?i64 = null,
    ended_by: ?GameEndedBy = null,
    replay_url: ?[]const u8 = null,
    match_id: ?i64 = null,
    winner_id: ?i64 = null,
};

pub const GameResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    game_number: i64,
    winner_side: ?GameWinnerSide,
    complexity_score: ?f64,
    turns_played: ?i64,
    duration_seconds: ?i64,
    ended_by: ?GameEndedBy,
    replay_url: ?[]const u8,
    match_id: i64,
    winner_id: ?i64,
};
