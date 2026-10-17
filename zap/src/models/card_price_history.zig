const std = @import("std");

pub const CardPriceHistory = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    price_date: []const u8 = "",
    avg_price: f64 = 0.0,
    min_price: f64 = 0.0,
    max_price: f64 = 0.0,
    volume: i64 = 0,
    foil: bool = false,
    card_id: i64 = 0,
};

pub const CardPriceHistoryCreateRequest = struct {
    price_date: []const u8 = "",
    avg_price: f64 = 0.0,
    min_price: f64 = 0.0,
    max_price: f64 = 0.0,
    volume: i64 = 0,
    foil: bool = false,
    card_id: i64 = 0,
};

pub const CardPriceHistoryUpdateRequest = struct {
    price_date: ?[]const u8 = null,
    avg_price: ?f64 = null,
    min_price: ?f64 = null,
    max_price: ?f64 = null,
    volume: ?i64 = null,
    foil: ?bool = null,
    card_id: ?i64 = null,
};

pub const CardPriceHistoryResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    price_date: []const u8,
    avg_price: f64,
    min_price: f64,
    max_price: f64,
    volume: i64,
    foil: bool,
    card_id: i64,
};
