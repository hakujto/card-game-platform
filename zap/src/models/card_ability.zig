const std = @import("std");

pub const CardAbilityAbilityType = enum {
    keyword,
    activated,
    triggered,
    static,
};

pub const CardAbilityTiming = enum {
    any,
    sorcery,
    instant,
    combat,
};

pub const CardAbility = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    ability_type: CardAbilityAbilityType = .keyword,
    keyword: ?[]const u8 = null,
    ability_text: []const u8 = "",
    timing: ?CardAbilityTiming = null,
    card_id: i64 = 0,
};

pub const CardAbilityCreateRequest = struct {
    ability_type: CardAbilityAbilityType = .keyword,
    keyword: ?[]const u8 = null,
    ability_text: []const u8 = "",
    timing: ?CardAbilityTiming = null,
    card_id: i64 = 0,
};

pub const CardAbilityUpdateRequest = struct {
    ability_type: ?CardAbilityAbilityType = null,
    keyword: ?[]const u8 = null,
    ability_text: ?[]const u8 = null,
    timing: ?CardAbilityTiming = null,
    card_id: ?i64 = null,
};

pub const CardAbilityResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    ability_type: CardAbilityAbilityType,
    keyword: ?[]const u8,
    ability_text: []const u8,
    timing: ?CardAbilityTiming,
    card_id: i64,
};
