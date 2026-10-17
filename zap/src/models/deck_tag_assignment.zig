const std = @import("std");

pub const DeckTagAssignment = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    deck_id: i64 = 0,
    tag_id: i64 = 0,
};

pub const DeckTagAssignmentCreateRequest = struct {
    deck_id: i64 = 0,
    tag_id: i64 = 0,
};

pub const DeckTagAssignmentUpdateRequest = struct {
    deck_id: ?i64 = null,
    tag_id: ?i64 = null,
};

pub const DeckTagAssignmentResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    deck_id: i64,
    tag_id: i64,
};
