const std = @import("std");

pub const CraftingRecipe = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    dust_cost: i64 = 0,
    is_available: bool = true,
    result_card_id: i64 = 0,
};

pub const CraftingRecipeCreateRequest = struct {
    dust_cost: i64 = 0,
    is_available: bool = true,
    result_card_id: i64 = 0,
};

pub const CraftingRecipeUpdateRequest = struct {
    dust_cost: ?i64 = null,
    is_available: ?bool = null,
    result_card_id: ?i64 = null,
};

pub const CraftingRecipeResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    dust_cost: i64,
    is_available: bool,
    result_card_id: i64,
};
