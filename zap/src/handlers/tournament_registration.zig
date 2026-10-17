const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/tournament_registration.zig");

fn getRequestUserId(r: zap.Request) ?i64 {
    if (r.getHeader("x-user-id")) |uid| {
        return std.fmt.parseInt(i64, uid, 10) catch null;
    }
    return null;
}

fn parseId(r: zap.Request) !i64 {
    const path = r.path orelse return error.MissingId;
    const sep = std.mem.lastIndexOfScalar(u8, path, '/') orelse return error.MissingId;
    const id_str = path[sep + 1..];
    return std.fmt.parseInt(i64, id_str, 10) catch error.InvalidId;
}

fn jsonError(r: zap.Request, status: zap.http.StatusCode, msg: []const u8) void {
    r.setStatus(status);
    var buf: [512]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "{{\"error\":\"{s}\"}}", .{msg}) catch return;
    r.sendJson(s) catch {};
}

fn jsonOk(r: zap.Request, body: []const u8) void {
    r.setStatus(.ok);
    r.sendJson(body) catch {};
}

fn validateTournamentRegistration(req: m.TournamentRegistrationCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Points earned must not be negative
    // rule: Final standing must be greater than zero
    // rule: Seed must be greater than zero
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const rows_json = db.queryJson(std.heap.page_allocator, "SELECT * FROM tournament_registrations", .{}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournament_registrations WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "tournament_registration not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.TournamentRegistrationCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateTournamentRegistration(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    const new_id = db.execInsert("INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", .{req.status, req.seed, req.final_standing, req.points_earned, req.registered_at, req.tournament_id, req.player_id, req.deck_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournament_registrations WHERE id = ?", .{new_id}) catch {
        jsonError(r, .internal_server_error, "fetch after insert failed");
        return;
    };
    defer std.heap.page_allocator.free(created_json);
    r.setStatus(.created);
    r.sendJson(created_json) catch {};
}

// behavior: withdraw
pub fn handleWithdraw(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement withdraw
    jsonError(r, .not_implemented, "withdraw not implemented");
}

// behavior: disqualify
pub fn handleDisqualify(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement disqualify
    jsonError(r, .not_implemented, "disqualify not implemented");
}

// behavior: promote_from_waitlist
pub fn handlePromoteFromWaitlist(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement promote_from_waitlist
    jsonError(r, .not_implemented, "promote_from_waitlist not implemented");
}

pub fn handleCollection(r: zap.Request) !void {
    const method = r.method orelse return;
    if (std.mem.eql(u8, method, "GET")) return handleList(r);
    if (std.mem.eql(u8, method, "POST")) return handleCreate(r);
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleItem(r: zap.Request) !void {
    const method = r.method orelse return;
    if (std.mem.eql(u8, method, "GET")) return handleGet(r);
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleAll(r: zap.Request) !void {
    const path = r.path orelse return;
    const prefix = "/api/tournament_registrations";
    const rest = if (path.len > prefix.len) path[prefix.len..] else "";
    // rest is "" or "/" for collection, "/N" for item, "/N/action" for behavior
    if (rest.len == 0 or std.mem.eql(u8, rest, "/")) {
        return handleCollection(r);
    }
    // Check for behavior sub-paths: /N/action
    if (rest.len > 1) {
        const after_slash = rest[1..];
        if (std.mem.indexOfScalar(u8, after_slash, '/')) |sep| {
            const action = after_slash[sep + 1..];
            if (std.mem.eql(u8, action, "withdraw")) return handleWithdraw(r);
            if (std.mem.eql(u8, action, "disqualify")) return handleDisqualify(r);
            if (std.mem.eql(u8, action, "promote")) return handlePromoteFromWaitlist(r);
        }
    }
    return handleItem(r);
}
