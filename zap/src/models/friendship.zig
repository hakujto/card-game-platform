const std = @import("std");

pub const FriendshipStatus = enum {
    pending,
    accepted,
    blocked,
};

pub const Friendship = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    status: FriendshipStatus = .pending,
    requester_id: i64 = 0,
    receiver_id: i64 = 0,
};

pub const FriendshipCreateRequest = struct {
    status: FriendshipStatus = .pending,
    requester_id: i64 = 0,
    receiver_id: i64 = 0,
};

pub const FriendshipUpdateRequest = struct {
    status: ?FriendshipStatus = null,
    requester_id: ?i64 = null,
    receiver_id: ?i64 = null,
};

pub const FriendshipResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    status: FriendshipStatus,
    requester_id: i64,
    receiver_id: i64,
};
