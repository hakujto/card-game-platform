const std = @import("std");

pub const CardSetSetType = enum {
    core,
    expansion,
    supplemental,
    masters,
    draft,
};

pub const CardSet = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    code: []const u8 = "",
    release_date: []const u8 = "",
    rotation_date: ?[]const u8 = null,
    set_type: CardSetSetType = .core,
    total_cards: i64 = 0,
    is_rotated: bool = false,
    description: ?[]const u8 = null,
    logo_url: ?[]const u8 = null,
};

pub const CardSetCreateRequest = struct {
    name: []const u8 = "",
    code: []const u8 = "",
    release_date: []const u8 = "",
    rotation_date: ?[]const u8 = null,
    set_type: CardSetSetType = .core,
    total_cards: i64 = 0,
    is_rotated: bool = false,
    description: ?[]const u8 = null,
    logo_url: ?[]const u8 = null,
};

pub const CardSetUpdateRequest = struct {
    name: ?[]const u8 = null,
    code: ?[]const u8 = null,
    release_date: ?[]const u8 = null,
    rotation_date: ?[]const u8 = null,
    set_type: ?CardSetSetType = null,
    total_cards: ?i64 = null,
    is_rotated: ?bool = null,
    description: ?[]const u8 = null,
    logo_url: ?[]const u8 = null,
};

pub const CardSetResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    code: []const u8,
    release_date: []const u8,
    rotation_date: ?[]const u8,
    set_type: CardSetSetType,
    total_cards: i64,
    is_rotated: bool,
    description: ?[]const u8,
    logo_url: ?[]const u8,
};
