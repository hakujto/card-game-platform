const std = @import("std");

pub const PlayerRank = enum {
    bronze,
    silver,
    gold,
    platinum,
    diamond,
    master,
    grandmaster,
};

pub const PlayerPreferredFormat = enum {
    standard,
    extended,
    legacy,
    vintage,
    commander,
    draft,
};

pub const Player = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    public_id: []const u8 = "",
    display_name: []const u8 = "",
    rank: PlayerRank = .bronze,
    rating: i64 = 1000,
    peak_rating: i64 = 1000,
    bio: ?[]const u8 = null,
    country_code: ?[]const u8 = null,
    avatar_url: ?[]const u8 = null,
    preferred_format: ?PlayerPreferredFormat = null,
    contact_email: ?[]const u8 = null,
    win_rate_cached: ?f64 = null,
    is_verified: bool = false,
    last_active_at: ?[]const u8 = null,
    user_id: ?i64 = null,
};

pub const PlayerCreateRequest = struct {
    public_id: []const u8 = "",
    display_name: []const u8 = "",
    rank: PlayerRank = .bronze,
    rating: i64 = 1000,
    peak_rating: i64 = 1000,
    bio: ?[]const u8 = null,
    country_code: ?[]const u8 = null,
    avatar_url: ?[]const u8 = null,
    preferred_format: ?PlayerPreferredFormat = null,
    contact_email: ?[]const u8 = null,
    win_rate_cached: ?f64 = null,
    is_verified: bool = false,
    last_active_at: ?[]const u8 = null,
    user_id: ?i64 = null,
};

pub const PlayerUpdateRequest = struct {
    public_id: ?[]const u8 = null,
    display_name: ?[]const u8 = null,
    rank: ?PlayerRank = null,
    bio: ?[]const u8 = null,
    country_code: ?[]const u8 = null,
    avatar_url: ?[]const u8 = null,
    preferred_format: ?PlayerPreferredFormat = null,
    contact_email: ?[]const u8 = null,
    win_rate_cached: ?f64 = null,
    is_verified: ?bool = null,
    last_active_at: ?[]const u8 = null,
    user_id: ?i64 = null,
};

pub const PlayerPutRequest = struct {
    public_id: ?[]const u8 = null,
    display_name: ?[]const u8 = null,
    rank: ?PlayerRank = null,
    contact_email: ?[]const u8 = null,
    win_rate_cached: ?f64 = null,
    is_verified: ?bool = null,
    last_active_at: ?[]const u8 = null,
    user_id: ?i64 = null,
};

pub const PlayerResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    public_id: []const u8,
    display_name: []const u8,
    rank: PlayerRank,
    rating: i64,
    peak_rating: i64,
    bio: ?[]const u8,
    country_code: ?[]const u8,
    avatar_url: ?[]const u8,
    preferred_format: ?PlayerPreferredFormat,
    contact_email: ?[]const u8,
    win_rate_cached: ?f64,
    is_verified: bool,
    lastActiveAt: ?[]const u8,
    user_id: ?i64,
};
