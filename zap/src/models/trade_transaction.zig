const std = @import("std");

pub const TradeTransactionStatus = enum {
    pending,
    completed,
    disputed,
    refunded,
};

pub const TradeTransaction = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    final_price: f64 = 0.0,
    platform_fee: f64 = 0.0,
    status: TradeTransactionStatus = .pending,
    completed_at: ?[]const u8 = null,
    listing_id: i64 = 0,
    buyer_id: i64 = 0,
    seller_id: i64 = 0,
};

pub const TradeTransactionCreateRequest = struct {
    final_price: f64 = 0.0,
    platform_fee: f64 = 0.0,
    status: TradeTransactionStatus = .pending,
    completed_at: ?[]const u8 = null,
    listing_id: i64 = 0,
    buyer_id: i64 = 0,
    seller_id: i64 = 0,
};

pub const TradeTransactionUpdateRequest = struct {
    final_price: ?f64 = null,
    platform_fee: ?f64 = null,
    status: ?TradeTransactionStatus = null,
    completed_at: ?[]const u8 = null,
    listing_id: ?i64 = null,
    buyer_id: ?i64 = null,
    seller_id: ?i64 = null,
};

pub const TradeTransactionResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    final_price: f64,
    platform_fee: f64,
    status: TradeTransactionStatus,
    completedAt: ?[]const u8,
    listing_id: i64,
    buyer_id: i64,
    seller_id: i64,
};
