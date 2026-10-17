const std = @import("std");

pub const DraftParticipant = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    seat_number: i64 = 0,
    joined_at: []const u8 = "",
    session_id: i64 = 0,
    player_id: i64 = 0,
};

pub const DraftParticipantCreateRequest = struct {
    seat_number: i64 = 0,
    joined_at: []const u8 = "",
    session_id: i64 = 0,
    player_id: i64 = 0,
};

pub const DraftParticipantUpdateRequest = struct {
    seat_number: ?i64 = null,
    joined_at: ?[]const u8 = null,
    session_id: ?i64 = null,
    player_id: ?i64 = null,
};

pub const DraftParticipantResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    seat_number: i64,
    joinedAt: []const u8,
    session_id: i64,
    player_id: i64,
};
