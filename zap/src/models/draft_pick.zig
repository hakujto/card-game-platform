const std = @import("std");

pub const DraftPick = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    pick_number: i64 = 0,
    pack_number: i64 = 0,
    picked_at: []const u8 = "",
    participant_id: i64 = 0,
    card_id: i64 = 0,
};

pub const DraftPickCreateRequest = struct {
    pick_number: i64 = 0,
    pack_number: i64 = 0,
    picked_at: []const u8 = "",
    participant_id: i64 = 0,
    card_id: i64 = 0,
};

pub const DraftPickUpdateRequest = struct {
    pick_number: ?i64 = null,
    pack_number: ?i64 = null,
    picked_at: ?[]const u8 = null,
    participant_id: ?i64 = null,
    card_id: ?i64 = null,
};

pub const DraftPickResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    pick_number: i64,
    pack_number: i64,
    pickedAt: []const u8,
    participant_id: i64,
    card_id: i64,
};
