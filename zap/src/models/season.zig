const std = @import("std");

pub const SeasonFormat = enum {
    standard,
    extended,
    legacy,
    vintage,
    commander,
    draft,
};

pub const Season = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    start_date: []const u8 = "",
    end_date: []const u8 = "",
    format: SeasonFormat = .standard,
    is_active: bool = false,
    reward_description: ?[]const u8 = null,
};

pub const SeasonCreateRequest = struct {
    name: []const u8 = "",
    start_date: []const u8 = "",
    end_date: []const u8 = "",
    format: SeasonFormat = .standard,
    is_active: bool = false,
    reward_description: ?[]const u8 = null,
};

pub const SeasonUpdateRequest = struct {
    name: ?[]const u8 = null,
    start_date: ?[]const u8 = null,
    end_date: ?[]const u8 = null,
    format: ?SeasonFormat = null,
    is_active: ?bool = null,
    reward_description: ?[]const u8 = null,
};

pub const SeasonResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    start_date: []const u8,
    end_date: []const u8,
    format: SeasonFormat,
    is_active: bool,
    reward_description: ?[]const u8,
};
