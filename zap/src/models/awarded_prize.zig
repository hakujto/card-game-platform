const std = @import("std");

pub const AwardedPrize = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    final_placement: i64 = 0,
    awarded_at: []const u8 = "",
    claimed: bool = false,
    claimed_at: ?[]const u8 = null,
    prize_id: i64 = 0,
    player_id: i64 = 0,
};

pub const AwardedPrizeCreateRequest = struct {
    final_placement: i64 = 0,
    awarded_at: []const u8 = "",
    claimed: bool = false,
    claimed_at: ?[]const u8 = null,
    prize_id: i64 = 0,
    player_id: i64 = 0,
};

pub const AwardedPrizeUpdateRequest = struct {
    claimed: ?bool = null,
    claimed_at: ?[]const u8 = null,
    prize_id: ?i64 = null,
    player_id: ?i64 = null,
};

pub const AwardedPrizeResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    final_placement: i64,
    awardedAt: []const u8,
    claimed: bool,
    claimedAt: ?[]const u8,
    prize_id: i64,
    player_id: i64,
};
