const std = @import("std");

pub const OrderStatus = enum {
    pending,
    paid,
    processing,
    shipped,
    completed,
    cancelled,
    refunded,
};

pub const OrderPaymentMethod = enum {
    card,
    pay_pal,
    crypto,
    platform_credits,
};

pub const Order = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    status: OrderStatus = .pending,
    total: f64 = 0,
    discount_applied: f64 = 0,
    currency: []const u8 = "USD",
    payment_method: ?OrderPaymentMethod = null,
    payment_reference: ?[]const u8 = null,
    shipping_address: ?[]const u8 = null,
    tracking_number: ?[]const u8 = null,
    paid_at: ?[]const u8 = null,
    shipped_at: ?[]const u8 = null,
    player_id: i64 = 0,
    coupon_id: ?i64 = null,
};

pub const OrderCreateRequest = struct {
    status: OrderStatus = .pending,
    total: f64 = 0,
    discount_applied: f64 = 0,
    currency: []const u8 = "USD",
    payment_method: ?OrderPaymentMethod = null,
    payment_reference: ?[]const u8 = null,
    shipping_address: ?[]const u8 = null,
    tracking_number: ?[]const u8 = null,
    paid_at: ?[]const u8 = null,
    shipped_at: ?[]const u8 = null,
    player_id: i64 = 0,
    coupon_id: ?i64 = null,
};

pub const OrderUpdateRequest = struct {
    total: ?f64 = null,
    discount_applied: ?f64 = null,
    currency: ?[]const u8 = null,
    payment_method: ?OrderPaymentMethod = null,
    payment_reference: ?[]const u8 = null,
    shipping_address: ?[]const u8 = null,
    tracking_number: ?[]const u8 = null,
    shipped_at: ?[]const u8 = null,
    player_id: ?i64 = null,
    coupon_id: ?i64 = null,
};

pub const OrderResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    status: OrderStatus,
    total: f64,
    discount_applied: f64,
    currency: []const u8,
    payment_method: ?OrderPaymentMethod,
    shipping_address: ?[]const u8,
    tracking_number: ?[]const u8,
    paidAt: ?[]const u8,
    shippedAt: ?[]const u8,
    player_id: i64,
    coupon_id: ?i64,
};

// Lifecycle state machine for Order
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Pending") and std.mem.eql(u8, to, "Paid")) return true;
    if (std.mem.eql(u8, from, "Paid") and std.mem.eql(u8, to, "Processing")) return true;
    if (std.mem.eql(u8, from, "Processing") and std.mem.eql(u8, to, "Shipped")) return true;
    if (std.mem.eql(u8, from, "Shipped") and std.mem.eql(u8, to, "Completed")) return true;
    if (std.mem.eql(u8, from, "Pending") and std.mem.eql(u8, to, "Cancelled")) return true;
    if (std.mem.eql(u8, from, "Paid") and std.mem.eql(u8, to, "Cancelled")) return true;
    if (std.mem.eql(u8, from, "Completed") and std.mem.eql(u8, to, "Refunded")) return true;
    return false;
}
