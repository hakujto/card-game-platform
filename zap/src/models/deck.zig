const std = @import("std");

pub const DeckFormat = enum {
    standard,
    extended,
    legacy,
    vintage,
    commander,
    draft,
};

pub const DeckArchetype = enum {
    aggro,
    control,
    midrange,
    combo,
    prison,
    tempo,
};

pub const Deck = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    description: ?[]const u8 = null,
    format: DeckFormat = .standard,
    is_public: bool = false,
    is_tournament_legal: bool = false,
    archetype: ?DeckArchetype = null,
    wins: i64 = 0,
    losses: i64 = 0,
    draws: i64 = 0,
    player_id: i64 = 0,
};

pub const DeckCreateRequest = struct {
    name: []const u8 = "",
    description: ?[]const u8 = null,
    format: DeckFormat = .standard,
    is_public: bool = false,
    is_tournament_legal: bool = false,
    archetype: ?DeckArchetype = null,
    wins: i64 = 0,
    losses: i64 = 0,
    draws: i64 = 0,
    player_id: i64 = 0,
};

pub const DeckUpdateRequest = struct {
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
    format: ?DeckFormat = null,
    is_public: ?bool = null,
    is_tournament_legal: ?bool = null,
    archetype: ?DeckArchetype = null,
    player_id: ?i64 = null,
};

pub const DeckPutRequest = struct {
    format: ?DeckFormat = null,
    is_public: ?bool = null,
    is_tournament_legal: ?bool = null,
    player_id: ?i64 = null,
};

pub const DeckResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    description: ?[]const u8,
    format: DeckFormat,
    is_public: bool,
    is_tournament_legal: bool,
    archetype: ?DeckArchetype,
    wins: i64,
    losses: i64,
    draws: i64,
    player_id: i64,
};
