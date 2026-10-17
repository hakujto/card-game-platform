const std = @import("std");

pub const OrderItem = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    quantity: i64 = 0,
    price_at_purchase: f64 = 0.0,
    foil: bool = false,
    order_id: i64 = 0,
    product_id: i64 = 0,
};

pub const OrderItemCreateRequest = struct {
    quantity: i64 = 0,
    price_at_purchase: f64 = 0.0,
    foil: bool = false,
    order_id: i64 = 0,
    product_id: i64 = 0,
};

pub const OrderItemUpdateRequest = struct {
    quantity: ?i64 = null,
    price_at_purchase: ?f64 = null,
    foil: ?bool = null,
    order_id: ?i64 = null,
    product_id: ?i64 = null,
};

pub const OrderItemResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    quantity: i64,
    price_at_purchase: f64,
    foil: bool,
    order_id: i64,
    product_id: i64,
};
