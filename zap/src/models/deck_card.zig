const std = @import("std");

pub const DeckCard = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    quantity: i64 = 1,
    is_commander: bool = false,
    deck_id: i64 = 0,
    card_id: i64 = 0,
};

pub const DeckCardCreateRequest = struct {
    quantity: i64 = 1,
    is_commander: bool = false,
    deck_id: i64 = 0,
    card_id: i64 = 0,
};

pub const DeckCardUpdateRequest = struct {
    quantity: ?i64 = null,
    is_commander: ?bool = null,
    deck_id: ?i64 = null,
    card_id: ?i64 = null,
};

pub const DeckCardResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    quantity: i64,
    is_commander: bool,
    deck_id: i64,
    card_id: i64,
};
