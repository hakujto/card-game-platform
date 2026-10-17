const std = @import("std");

pub const ProductProductType = enum {
    single_card,
    booster_pack,
    bundle,
    preconstructed_deck,
    accessory,
};

pub const Product = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    name: []const u8 = "",
    product_type: ProductProductType = .single_card,
    price: f64 = 0.0,
    stock: i64 = 0,
    active: bool = true,
    discount_percent: i64 = 0,
    description: ?[]const u8 = null,
    image_url: ?[]const u8 = null,
    featured: bool = false,
    card_id: ?i64 = null,
    card_set_id: ?i64 = null,
};

pub const ProductCreateRequest = struct {
    name: []const u8 = "",
    product_type: ProductProductType = .single_card,
    price: f64 = 0.0,
    stock: i64 = 0,
    active: bool = true,
    discount_percent: i64 = 0,
    description: ?[]const u8 = null,
    image_url: ?[]const u8 = null,
    featured: bool = false,
    card_id: ?i64 = null,
    card_set_id: ?i64 = null,
};

pub const ProductUpdateRequest = struct {
    name: ?[]const u8 = null,
    product_type: ?ProductProductType = null,
    price: ?f64 = null,
    stock: ?i64 = null,
    active: ?bool = null,
    discount_percent: ?i64 = null,
    description: ?[]const u8 = null,
    image_url: ?[]const u8 = null,
    featured: ?bool = null,
    card_id: ?i64 = null,
    card_set_id: ?i64 = null,
};

pub const ProductPutRequest = struct {
    name: ?[]const u8 = null,
    product_type: ?ProductProductType = null,
    price: ?f64 = null,
    stock: ?i64 = null,
    active: ?bool = null,
    discount_percent: ?i64 = null,
    image_url: ?[]const u8 = null,
    card_id: ?i64 = null,
    card_set_id: ?i64 = null,
};

pub const ProductResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    name: []const u8,
    product_type: ProductProductType,
    price: f64,
    stock: i64,
    active: bool,
    discount_percent: i64,
    description: ?[]const u8,
    image_url: ?[]const u8,
    featured: bool,
    card_id: ?i64,
    card_set_id: ?i64,
};
