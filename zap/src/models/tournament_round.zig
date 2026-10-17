const std = @import("std");

pub const TournamentRoundStatus = enum {
    pending,
    active,
    completed,
};

pub const TournamentRound = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    round_number: i64 = 0,
    status: TournamentRoundStatus = .pending,
    started_at: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    time_limit_minutes: i64 = 50,
    tournament_id: i64 = 0,
};

pub const TournamentRoundCreateRequest = struct {
    round_number: i64 = 0,
    status: TournamentRoundStatus = .pending,
    started_at: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    time_limit_minutes: i64 = 50,
    tournament_id: i64 = 0,
};

pub const TournamentRoundUpdateRequest = struct {
    round_number: ?i64 = null,
    status: ?TournamentRoundStatus = null,
    started_at: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    time_limit_minutes: ?i64 = null,
    tournament_id: ?i64 = null,
};

pub const TournamentRoundResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    round_number: i64,
    status: TournamentRoundStatus,
    startedAt: ?[]const u8,
    endedAt: ?[]const u8,
    time_limit_minutes: i64,
    tournament_id: i64,
};
