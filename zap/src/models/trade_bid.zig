const std = @import("std");

pub const TradeBid = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    amount: f64 = 0.0,
    placed_at: []const u8 = "",
    is_winning: bool = false,
    listing_id: i64 = 0,
    bidder_id: i64 = 0,
};

pub const TradeBidCreateRequest = struct {
    amount: f64 = 0.0,
    placed_at: []const u8 = "",
    is_winning: bool = false,
    listing_id: i64 = 0,
    bidder_id: i64 = 0,
};

pub const TradeBidUpdateRequest = struct {
    amount: ?f64 = null,
    placed_at: ?[]const u8 = null,
    is_winning: ?bool = null,
    listing_id: ?i64 = null,
    bidder_id: ?i64 = null,
};

pub const TradeBidResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    amount: f64,
    placedAt: []const u8,
    is_winning: bool,
    listing_id: i64,
    bidder_id: i64,
};
