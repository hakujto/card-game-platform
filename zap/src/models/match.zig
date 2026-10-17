const std = @import("std");

pub const MatchStatus = enum {
    pending,
    active,
    completed,
    b_y_e,
    draw,
};

pub const Match = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    table_number: ?i64 = null,
    status: MatchStatus = .pending,
    player1_wins: i64 = 0,
    player2_wins: i64 = 0,
    started_at: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    result_notes: ?[]const u8 = null,
    round_id: i64 = 0,
    player1_id: i64 = 0,
    player2_id: ?i64 = null,
};

pub const MatchCreateRequest = struct {
    table_number: ?i64 = null,
    status: MatchStatus = .pending,
    player1_wins: i64 = 0,
    player2_wins: i64 = 0,
    started_at: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    result_notes: ?[]const u8 = null,
    round_id: i64 = 0,
    player1_id: i64 = 0,
    player2_id: ?i64 = null,
};

pub const MatchUpdateRequest = struct {
    table_number: ?i64 = null,
    status: ?MatchStatus = null,
    player1_wins: ?i64 = null,
    player2_wins: ?i64 = null,
    started_at: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    result_notes: ?[]const u8 = null,
    round_id: ?i64 = null,
    player1_id: ?i64 = null,
    player2_id: ?i64 = null,
};

pub const MatchResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    table_number: ?i64,
    status: MatchStatus,
    player1_wins: i64,
    player2_wins: i64,
    startedAt: ?[]const u8,
    endedAt: ?[]const u8,
    result_notes: ?[]const u8,
    round_id: i64,
    player1_id: i64,
    player2_id: ?i64,
};

// Lifecycle state machine for Match
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Pending") and std.mem.eql(u8, to, "Active")) return true;
    if (std.mem.eql(u8, from, "Active") and std.mem.eql(u8, to, "Completed")) return true;
    if (std.mem.eql(u8, from, "Active") and std.mem.eql(u8, to, "Draw")) return true;
    if (std.mem.eql(u8, from, "Pending") and std.mem.eql(u8, to, "BYE")) return true;
    return false;
}
