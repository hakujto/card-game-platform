const std = @import("std");

pub const PlayerAchievement = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    earned_at: []const u8 = "",
    progress: i64 = 0,
    is_completed: bool = false,
    player_id: i64 = 0,
    achievement_id: i64 = 0,
};

pub const PlayerAchievementCreateRequest = struct {
    earned_at: []const u8 = "",
    progress: i64 = 0,
    is_completed: bool = false,
    player_id: i64 = 0,
    achievement_id: i64 = 0,
};

pub const PlayerAchievementUpdateRequest = struct {
    earned_at: ?[]const u8 = null,
    progress: ?i64 = null,
    is_completed: ?bool = null,
    player_id: ?i64 = null,
    achievement_id: ?i64 = null,
};

pub const PlayerAchievementResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    earnedAt: []const u8,
    progress: i64,
    is_completed: bool,
    player_id: i64,
    achievement_id: i64,
};
