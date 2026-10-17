const std = @import("std");

pub const DeckSideboardCard = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    quantity: i64 = 1,
    deck_id: i64 = 0,
    card_id: i64 = 0,
};

pub const DeckSideboardCardCreateRequest = struct {
    quantity: i64 = 1,
    deck_id: i64 = 0,
    card_id: i64 = 0,
};

pub const DeckSideboardCardUpdateRequest = struct {
    quantity: ?i64 = null,
    deck_id: ?i64 = null,
    card_id: ?i64 = null,
};

pub const DeckSideboardCardResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    quantity: i64,
    deck_id: i64,
    card_id: i64,
};
