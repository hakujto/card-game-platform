const std = @import("std");

pub const ArticleTag = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    slug: []const u8 = "",
};

pub const ArticleTagCreateRequest = struct {
    name: []const u8 = "",
    slug: []const u8 = "",
};

pub const ArticleTagUpdateRequest = struct {
    name: ?[]const u8 = null,
    slug: ?[]const u8 = null,
};

pub const ArticleTagResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    slug: []const u8,
};
