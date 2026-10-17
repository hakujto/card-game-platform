const std = @import("std");

pub const TournamentStatus = enum {
    draft,
    registration,
    ongoing,
    completed,
    cancelled,
};

pub const TournamentFormat = enum {
    standard,
    extended,
    legacy,
    vintage,
    commander,
    draft,
};

pub const TournamentTournamentType = enum {
    swiss,
    single_elimination,
    double_elimination,
    round_robin,
};

pub const Tournament = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    public_id: []const u8 = "",
    name: []const u8 = "",
    description: ?[]const u8 = null,
    status: TournamentStatus = .draft,
    bracket_data: ?[]const u8 = null,
    format: TournamentFormat = .standard,
    tournament_type: TournamentTournamentType = .swiss,
    max_players: i64 = 0,
    entry_fee: f64 = 0,
    prize_pool: f64 = 0,
    start_time: []const u8 = "",
    end_time: ?[]const u8 = null,
    is_online: bool = true,
    location: ?[]const u8 = null,
    rules_text: ?[]const u8 = null,
    season_id: i64 = 0,
    organizer_id: i64 = 0,
};

pub const TournamentCreateRequest = struct {
    public_id: []const u8 = "",
    name: []const u8 = "",
    description: ?[]const u8 = null,
    status: TournamentStatus = .draft,
    bracket_data: ?[]const u8 = null,
    format: TournamentFormat = .standard,
    tournament_type: TournamentTournamentType = .swiss,
    max_players: i64 = 0,
    entry_fee: f64 = 0,
    prize_pool: f64 = 0,
    start_time: []const u8 = "",
    end_time: ?[]const u8 = null,
    is_online: bool = true,
    location: ?[]const u8 = null,
    rules_text: ?[]const u8 = null,
    season_id: i64 = 0,
    organizer_id: i64 = 0,
};

pub const TournamentUpdateRequest = struct {
    public_id: ?[]const u8 = null,
    name: ?[]const u8 = null,
    description: ?[]const u8 = null,
    bracket_data: ?[]const u8 = null,
    format: ?TournamentFormat = null,
    tournament_type: ?TournamentTournamentType = null,
    max_players: ?i64 = null,
    entry_fee: ?f64 = null,
    prize_pool: ?f64 = null,
    start_time: ?[]const u8 = null,
    end_time: ?[]const u8 = null,
    is_online: ?bool = null,
    location: ?[]const u8 = null,
    rules_text: ?[]const u8 = null,
    season_id: ?i64 = null,
    organizer_id: ?i64 = null,
};

pub const TournamentPutRequest = struct {
    public_id: ?[]const u8 = null,
    name: ?[]const u8 = null,
    bracket_data: ?[]const u8 = null,
    format: ?TournamentFormat = null,
    tournament_type: ?TournamentTournamentType = null,
    max_players: ?i64 = null,
    entry_fee: ?f64 = null,
    prize_pool: ?f64 = null,
    start_time: ?[]const u8 = null,
    end_time: ?[]const u8 = null,
    is_online: ?bool = null,
    season_id: ?i64 = null,
    organizer_id: ?i64 = null,
};

pub const TournamentResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    public_id: []const u8,
    name: []const u8,
    description: ?[]const u8,
    status: TournamentStatus,
    bracket_data: ?[]const u8,
    format: TournamentFormat,
    tournament_type: TournamentTournamentType,
    max_players: i64,
    entry_fee: f64,
    prize_pool: f64,
    startTime: []const u8,
    endTime: ?[]const u8,
    is_online: bool,
    location: ?[]const u8,
    rules_text: ?[]const u8,
    season_id: i64,
    organizer_id: i64,
};

// Lifecycle state machine for Tournament
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Draft") and std.mem.eql(u8, to, "Registration")) return true;
    if (std.mem.eql(u8, from, "Registration") and std.mem.eql(u8, to, "Ongoing")) return true;
    if (std.mem.eql(u8, from, "Registration") and std.mem.eql(u8, to, "Cancelled")) return true;
    if (std.mem.eql(u8, from, "Ongoing") and std.mem.eql(u8, to, "Completed")) return true;
    if (std.mem.eql(u8, from, "Ongoing") and std.mem.eql(u8, to, "Cancelled")) return true;
    return false;
}
