const std = @import("std");

pub const TournamentJudgeRole = enum {
    head_judge,
    judge,
    scorekeeper_judge,
};

pub const TournamentJudge = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    role: TournamentJudgeRole = .head_judge,
    tournament_id: i64 = 0,
    player_id: i64 = 0,
};

pub const TournamentJudgeCreateRequest = struct {
    role: TournamentJudgeRole = .head_judge,
    tournament_id: i64 = 0,
    player_id: i64 = 0,
};

pub const TournamentJudgeUpdateRequest = struct {
    role: ?TournamentJudgeRole = null,
    tournament_id: ?i64 = null,
    player_id: ?i64 = null,
};

pub const TournamentJudgeResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    role: TournamentJudgeRole,
    tournament_id: i64,
    player_id: i64,
};
