const std = @import("std");

pub const DraftSessionStatus = enum {
    waiting_for_players,
    drafting,
    completed,
    abandoned,
};

pub const DraftSessionDraftType = enum {
    booster,
    cube,
    rochester,
};

pub const DraftSession = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    status: DraftSessionStatus = .waiting_for_players,
    draft_type: DraftSessionDraftType = .booster,
    pack_contents: ?[]const u8 = null,
    seats: i64 = 8,
    time_per_pick_seconds: i64 = 30,
    completed_at: ?[]const u8 = null,
    card_set_id: i64 = 0,
};

pub const DraftSessionCreateRequest = struct {
    status: DraftSessionStatus = .waiting_for_players,
    draft_type: DraftSessionDraftType = .booster,
    pack_contents: ?[]const u8 = null,
    seats: i64 = 8,
    time_per_pick_seconds: i64 = 30,
    completed_at: ?[]const u8 = null,
    card_set_id: i64 = 0,
};

pub const DraftSessionUpdateRequest = struct {
    status: ?DraftSessionStatus = null,
    draft_type: ?DraftSessionDraftType = null,
    pack_contents: ?[]const u8 = null,
    seats: ?i64 = null,
    time_per_pick_seconds: ?i64 = null,
    completed_at: ?[]const u8 = null,
    card_set_id: ?i64 = null,
};

pub const DraftSessionResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    status: DraftSessionStatus,
    draft_type: DraftSessionDraftType,
    pack_contents: ?[]const u8,
    seats: i64,
    time_per_pick_seconds: i64,
    completedAt: ?[]const u8,
    card_set_id: i64,
};

// Lifecycle state machine for DraftSession
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "WaitingForPlayers") and std.mem.eql(u8, to, "Drafting")) return true;
    if (std.mem.eql(u8, from, "Drafting") and std.mem.eql(u8, to, "Completed")) return true;
    if (std.mem.eql(u8, from, "Drafting") and std.mem.eql(u8, to, "Abandoned")) return true;
    if (std.mem.eql(u8, from, "WaitingForPlayers") and std.mem.eql(u8, to, "Abandoned")) return true;
    return false;
}
