const std = @import("std");

pub const CardRuling = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    ruling_text: []const u8 = "",
    published_at: []const u8 = "",
    source: []const u8 = "",
    card_id: i64 = 0,
};

pub const CardRulingCreateRequest = struct {
    ruling_text: []const u8 = "",
    published_at: []const u8 = "",
    source: []const u8 = "",
    card_id: i64 = 0,
};

pub const CardRulingUpdateRequest = struct {
    ruling_text: ?[]const u8 = null,
    published_at: ?[]const u8 = null,
    source: ?[]const u8 = null,
    card_id: ?i64 = null,
};

pub const CardRulingResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    ruling_text: []const u8,
    published_at: []const u8,
    source: []const u8,
    card_id: i64,
};
