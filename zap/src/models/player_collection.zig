const std = @import("std");

pub const PlayerCollectionCondition = enum {
    mint,
    near_mint,
    excellent,
    good,
    played,
};

pub const PlayerCollectionAcquiredVia = enum {
    purchase,
    trade,
    tournament_reward,
    pack,
    craft,
};

pub const PlayerCollection = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    quantity: i64 = 1,
    foil: bool = false,
    condition: PlayerCollectionCondition = .mint,
    acquired_at: []const u8 = "",
    acquired_via: PlayerCollectionAcquiredVia = .purchase,
    player_id: i64 = 0,
    card_id: i64 = 0,
};

pub const PlayerCollectionCreateRequest = struct {
    quantity: i64 = 1,
    foil: bool = false,
    condition: PlayerCollectionCondition = .mint,
    acquired_at: []const u8 = "",
    acquired_via: PlayerCollectionAcquiredVia = .purchase,
    player_id: i64 = 0,
    card_id: i64 = 0,
};

pub const PlayerCollectionUpdateRequest = struct {
    quantity: ?i64 = null,
    foil: ?bool = null,
    condition: ?PlayerCollectionCondition = null,
    acquired_at: ?[]const u8 = null,
    acquired_via: ?PlayerCollectionAcquiredVia = null,
    player_id: ?i64 = null,
    card_id: ?i64 = null,
};

pub const PlayerCollectionResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    quantity: i64,
    foil: bool,
    condition: PlayerCollectionCondition,
    acquiredAt: []const u8,
    acquired_via: PlayerCollectionAcquiredVia,
    player_id: i64,
    card_id: i64,
};
