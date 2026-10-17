const std = @import("std");

pub const TradeDisputeStatus = enum {
    open,
    under_review,
    resolved,
    escalated,
};

pub const TradeDisputeReason = enum {
    item_not_received,
    item_not_as_described,
    fraud_suspected,
    other,
};

pub const TradeDispute = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    status: TradeDisputeStatus = .open,
    reason: TradeDisputeReason = .item_not_received,
    description: []const u8 = "",
    resolution: ?[]const u8 = null,
    opened_at: []const u8 = "",
    resolved_at: ?[]const u8 = null,
    transaction_id: i64 = 0,
    opened_by_id: i64 = 0,
    resolved_by_id: ?i64 = null,
};

pub const TradeDisputeCreateRequest = struct {
    status: TradeDisputeStatus = .open,
    reason: TradeDisputeReason = .item_not_received,
    description: []const u8 = "",
    resolution: ?[]const u8 = null,
    opened_at: []const u8 = "",
    resolved_at: ?[]const u8 = null,
    transaction_id: i64 = 0,
    opened_by_id: i64 = 0,
    resolved_by_id: ?i64 = null,
};

pub const TradeDisputeUpdateRequest = struct {
    status: ?TradeDisputeStatus = null,
    reason: ?TradeDisputeReason = null,
    description: ?[]const u8 = null,
    resolution: ?[]const u8 = null,
    opened_at: ?[]const u8 = null,
    resolved_at: ?[]const u8 = null,
    transaction_id: ?i64 = null,
    opened_by_id: ?i64 = null,
    resolved_by_id: ?i64 = null,
};

pub const TradeDisputeResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    status: TradeDisputeStatus,
    reason: TradeDisputeReason,
    description: []const u8,
    resolution: ?[]const u8,
    openedAt: []const u8,
    resolvedAt: ?[]const u8,
    transaction_id: i64,
    opened_by_id: i64,
    resolved_by_id: ?i64,
};

// Lifecycle state machine for TradeDispute
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Open") and std.mem.eql(u8, to, "UnderReview")) return true;
    if (std.mem.eql(u8, from, "UnderReview") and std.mem.eql(u8, to, "Resolved")) return true;
    if (std.mem.eql(u8, from, "UnderReview") and std.mem.eql(u8, to, "Escalated")) return true;
    if (std.mem.eql(u8, from, "Escalated") and std.mem.eql(u8, to, "Resolved")) return true;
    return false;
}
