const std = @import("std");

pub const StreamStatus = enum {
    scheduled,
    live,
    ended,
};

pub const StreamPlatform = enum {
    twitch,
    you_tube,
    kick_stream,
    platform,
};

pub const StreamLanguage = enum {
    e_n,
    d_e,
    f_r,
    i_t,
    e_s,
    j_p,
    p_t,
};

pub const Stream = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    title: []const u8 = "",
    stream_url: []const u8 = "",
    status: StreamStatus = .scheduled,
    platform: StreamPlatform = .twitch,
    language: StreamLanguage = .e_n,
    is_official: bool = false,
    viewer_count_peak: i64 = 0,
    scheduled_start: []const u8 = "",
    actual_start: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    vod_url: ?[]const u8 = null,
    tournament_id: ?i64 = null,
    streamer_id: i64 = 0,
};

pub const StreamCreateRequest = struct {
    title: []const u8 = "",
    stream_url: []const u8 = "",
    status: StreamStatus = .scheduled,
    platform: StreamPlatform = .twitch,
    language: StreamLanguage = .e_n,
    is_official: bool = false,
    viewer_count_peak: i64 = 0,
    scheduled_start: []const u8 = "",
    actual_start: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    vod_url: ?[]const u8 = null,
    tournament_id: ?i64 = null,
    streamer_id: i64 = 0,
};

pub const StreamUpdateRequest = struct {
    title: ?[]const u8 = null,
    stream_url: ?[]const u8 = null,
    status: ?StreamStatus = null,
    platform: ?StreamPlatform = null,
    language: ?StreamLanguage = null,
    is_official: ?bool = null,
    viewer_count_peak: ?i64 = null,
    scheduled_start: ?[]const u8 = null,
    actual_start: ?[]const u8 = null,
    ended_at: ?[]const u8 = null,
    vod_url: ?[]const u8 = null,
    tournament_id: ?i64 = null,
    streamer_id: ?i64 = null,
};

pub const StreamResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    title: []const u8,
    stream_url: []const u8,
    status: StreamStatus,
    platform: StreamPlatform,
    language: StreamLanguage,
    is_official: bool,
    viewer_count_peak: i64,
    scheduledStart: []const u8,
    actualStart: ?[]const u8,
    endedAt: ?[]const u8,
    vod_url: ?[]const u8,
    tournament_id: ?i64,
    streamer_id: i64,
};

// Lifecycle state machine for Stream
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Scheduled") and std.mem.eql(u8, to, "Live")) return true;
    if (std.mem.eql(u8, from, "Live") and std.mem.eql(u8, to, "Ended")) return true;
    return false;
}
