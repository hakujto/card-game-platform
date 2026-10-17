const std = @import("std");

pub const AchievementRarity = enum {
    common,
    uncommon,
    rare,
    epic,
    legendary,
};

pub const Achievement = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    description: []const u8 = "",
    icon_url: ?[]const u8 = null,
    points: i64 = 10,
    rarity: AchievementRarity = .common,
    is_hidden: bool = false,
};

pub const AchievementCreateRequest = struct {
    name: []const u8 = "",
    description: []const u8 = "",
    icon_url: ?[]const u8 = null,
    points: i64 = 10,
    rarity: AchievementRarity = .common,
    is_hidden: bool = false,
};

pub const AchievementUpdateRequest = struct {
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
    icon_url: ?[]const u8 = null,
    points: ?i64 = null,
    rarity: ?AchievementRarity = null,
    is_hidden: ?bool = null,
};

pub const AchievementResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    description: []const u8,
    icon_url: ?[]const u8,
    points: i64,
    rarity: AchievementRarity,
    is_hidden: bool,
};
