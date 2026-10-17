const std = @import("std");

pub const DeckTag = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    slug: ?[]const u8 = null,
    color: ?[]const u8 = null,
};

pub const DeckTagCreateRequest = struct {
    name: []const u8 = "",
    slug: ?[]const u8 = null,
    color: ?[]const u8 = null,
};

pub const DeckTagUpdateRequest = struct {
    name: ?[]const u8 = null,
    slug: ?[]const u8 = null,
    color: ?[]const u8 = null,
};

pub const DeckTagResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    slug: ?[]const u8,
    color: ?[]const u8,
};
