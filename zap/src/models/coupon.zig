const std = @import("std");

pub const CouponDiscountType = enum {
    percent,
    fixed,
};

pub const Coupon = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    code: []const u8 = "",
    discount_type: CouponDiscountType = .percent,
    discount_value: f64 = 0.0,
    min_order_value: f64 = 0,
    max_uses: ?i64 = null,
    uses_count: i64 = 0,
    valid_from: []const u8 = "",
    valid_until: []const u8 = "",
    is_active: bool = true,
};

pub const CouponCreateRequest = struct {
    code: []const u8 = "",
    discount_type: CouponDiscountType = .percent,
    discount_value: f64 = 0.0,
    min_order_value: f64 = 0,
    max_uses: ?i64 = null,
    uses_count: i64 = 0,
    valid_from: []const u8 = "",
    valid_until: []const u8 = "",
    is_active: bool = true,
};

pub const CouponUpdateRequest = struct {
    code: ?[]const u8 = null,
    discount_type: ?CouponDiscountType = null,
    discount_value: ?f64 = null,
    min_order_value: ?f64 = null,
    max_uses: ?i64 = null,
    uses_count: ?i64 = null,
    valid_from: ?[]const u8 = null,
    valid_until: ?[]const u8 = null,
    is_active: ?bool = null,
};

pub const CouponResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    code: []const u8,
    discount_type: CouponDiscountType,
    discount_value: f64,
    min_order_value: f64,
    valid_from: []const u8,
    valid_until: []const u8,
    is_active: bool,
};
