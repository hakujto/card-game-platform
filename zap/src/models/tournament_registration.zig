const std = @import("std");

pub const TournamentRegistrationStatus = enum {
    registered,
    waitlisted,
    withdrawn,
    disqualified,
};

pub const TournamentRegistration = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    status: TournamentRegistrationStatus = .registered,
    seed: ?i64 = null,
    final_standing: ?i64 = null,
    points_earned: i64 = 0,
    registered_at: []const u8 = "",
    tournament_id: i64 = 0,
    player_id: i64 = 0,
    deck_id: i64 = 0,
};

pub const TournamentRegistrationCreateRequest = struct {
    status: TournamentRegistrationStatus = .registered,
    seed: ?i64 = null,
    final_standing: ?i64 = null,
    points_earned: i64 = 0,
    registered_at: []const u8 = "",
    tournament_id: i64 = 0,
    player_id: i64 = 0,
    deck_id: i64 = 0,
};

pub const TournamentRegistrationUpdateRequest = struct {
    status: ?TournamentRegistrationStatus = null,
    seed: ?i64 = null,
    final_standing: ?i64 = null,
    points_earned: ?i64 = null,
    registered_at: ?[]const u8 = null,
    tournament_id: ?i64 = null,
    player_id: ?i64 = null,
    deck_id: ?i64 = null,
};

pub const TournamentRegistrationResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    status: TournamentRegistrationStatus,
    seed: ?i64,
    final_standing: ?i64,
    points_earned: i64,
    registeredAt: []const u8,
    tournament_id: i64,
    player_id: i64,
    deck_id: i64,
};
