const std = @import("std");

pub const CraftingIngredient = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    quantity: i64 = 1,
    recipe_id: i64 = 0,
    card_id: i64 = 0,
};

pub const CraftingIngredientCreateRequest = struct {
    quantity: i64 = 1,
    recipe_id: i64 = 0,
    card_id: i64 = 0,
};

pub const CraftingIngredientUpdateRequest = struct {
    quantity: ?i64 = null,
    recipe_id: ?i64 = null,
    card_id: ?i64 = null,
};

pub const CraftingIngredientResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    quantity: i64,
    recipe_id: i64,
    card_id: i64,
};
