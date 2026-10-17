const std = @import("std");

pub const TradeListingStatus = enum {
    active,
    sold,
    expired,
    cancelled,
    pending,
};

pub const TradeListingListingType = enum {
    fixed_price,
    auction,
    trade_offer,
};

pub const TradeListingCondition = enum {
    mint,
    near_mint,
    excellent,
    good,
    played,
};

pub const TradeListing = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    public_id: []const u8 = "",
    status: TradeListingStatus = .active,
    listing_type: TradeListingListingType = .fixed_price,
    asking_price: ?f64 = null,
    auction_start_price: ?f64 = null,
    auction_current_bid: ?f64 = null,
    auction_end_time: ?[]const u8 = null,
    foil: bool = false,
    condition: TradeListingCondition = .mint,
    quantity: i64 = 1,
    description: ?[]const u8 = null,
    expires_at: ?[]const u8 = null,
    seller_id: i64 = 0,
    card_id: i64 = 0,
};

pub const TradeListingCreateRequest = struct {
    public_id: []const u8 = "",
    status: TradeListingStatus = .active,
    listing_type: TradeListingListingType = .fixed_price,
    asking_price: ?f64 = null,
    auction_start_price: ?f64 = null,
    auction_current_bid: ?f64 = null,
    auction_end_time: ?[]const u8 = null,
    foil: bool = false,
    condition: TradeListingCondition = .mint,
    quantity: i64 = 1,
    description: ?[]const u8 = null,
    expires_at: ?[]const u8 = null,
    seller_id: i64 = 0,
    card_id: i64 = 0,
};

pub const TradeListingUpdateRequest = struct {
    public_id: ?[]const u8 = null,
    listing_type: ?TradeListingListingType = null,
    asking_price: ?f64 = null,
    auction_start_price: ?f64 = null,
    auction_current_bid: ?f64 = null,
    auction_end_time: ?[]const u8 = null,
    foil: ?bool = null,
    condition: ?TradeListingCondition = null,
    quantity: ?i64 = null,
    description: ?[]const u8 = null,
    expires_at: ?[]const u8 = null,
    seller_id: ?i64 = null,
    card_id: ?i64 = null,
};

pub const TradeListingResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    public_id: []const u8,
    status: TradeListingStatus,
    listing_type: TradeListingListingType,
    asking_price: ?f64,
    auction_start_price: ?f64,
    auction_current_bid: ?f64,
    auctionEndTime: ?[]const u8,
    foil: bool,
    condition: TradeListingCondition,
    quantity: i64,
    description: ?[]const u8,
    expiresAt: ?[]const u8,
    seller_id: i64,
    card_id: i64,
};

// Lifecycle state machine for TradeListing
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Pending") and std.mem.eql(u8, to, "Active")) return true;
    if (std.mem.eql(u8, from, "Active") and std.mem.eql(u8, to, "Sold")) return true;
    if (std.mem.eql(u8, from, "Active") and std.mem.eql(u8, to, "Expired")) return true;
    if (std.mem.eql(u8, from, "Active") and std.mem.eql(u8, to, "Cancelled")) return true;
    return false;
}
