const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/player.zig");

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

fn validatePlayer(req: m.PlayerCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Rating must be between 0 and 9999
    // rule: Peak rating must be greater than or equal to current rating
    // rule: Display name must not be empty
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM players WHERE display_name LIKE '%' || ? || '%'", .{q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM players", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM players WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "player not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.PlayerCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validatePlayer(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if (db.exists("SELECT 1 FROM players WHERE public_id = ?", .{req.public_id})) {
        jsonError(r, .conflict, "public_id already exists");
        return;
    }
    if (db.exists("SELECT 1 FROM players WHERE display_name = ?", .{req.display_name})) {
        jsonError(r, .conflict, "display_name already exists");
        return;
    }
    const new_id = db.execInsert("INSERT INTO players (public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.public_id, req.display_name, req.rank, req.rating, req.peak_rating, req.bio, req.country_code, req.avatar_url, req.preferred_format, req.contact_email, req.win_rate_cached, req.is_verified, req.last_active_at, req.user_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    // hook: after create — initialize_collection
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM players WHERE id = ?", .{new_id}) catch {
        jsonError(r, .internal_server_error, "fetch after insert failed");
        return;
    };
    defer std.heap.page_allocator.free(created_json);
    r.setStatus(.created);
    r.sendJson(created_json) catch {};
}

pub fn handleUpdate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const patch = std.json.parseFromSlice(m.PlayerUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE players SET public_id = COALESCE(?, public_id), display_name = COALESCE(?, display_name), rank = COALESCE(?, rank), bio = COALESCE(?, bio), country_code = COALESCE(?, country_code), avatar_url = COALESCE(?, avatar_url), preferred_format = COALESCE(?, preferred_format), contact_email = COALESCE(?, contact_email), win_rate_cached = COALESCE(?, win_rate_cached), is_verified = COALESCE(?, is_verified), last_active_at = COALESCE(?, last_active_at), user_id = COALESCE(?, user_id), updated_at = datetime('now') WHERE id = ?", .{upd.public_id, upd.display_name, upd.rank, upd.bio, upd.country_code, upd.avatar_url, upd.preferred_format, upd.contact_email, upd.win_rate_cached, upd.is_verified, upd.last_active_at, upd.user_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM players WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: promote
pub fn handlePromote(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement promote
    jsonError(r, .not_implemented, "promote not implemented");
}

// behavior: demote
pub fn handleDemote(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement demote
    jsonError(r, .not_implemented, "demote not implemented");
}

// behavior: record_win
pub fn handleRecordWin(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement record_win
    jsonError(r, .not_implemented, "record_win not implemented");
}

// behavior: record_loss
pub fn handleRecordLoss(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement record_loss
    jsonError(r, .not_implemented, "record_loss not implemented");
}

// behavior: win_rate
pub fn handleWinRate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement win_rate
    jsonError(r, .not_implemented, "win_rate not implemented");
}

// behavior: verify
pub fn handleVerify(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement verify
    jsonError(r, .not_implemented, "verify not implemented");
}

// behavior: update_rating
pub fn handleUpdateRating(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement update_rating
    jsonError(r, .not_implemented, "update_rating not implemented");
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
    if (std.mem.eql(u8, method, "PATCH")) return handleUpdate(r);
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleAll(r: zap.Request) !void {
    const path = r.path orelse return;
    const prefix = "/api/players";
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
            if (std.mem.eql(u8, action, "promote")) return handlePromote(r);
            if (std.mem.eql(u8, action, "demote")) return handleDemote(r);
            if (std.mem.eql(u8, action, "win")) return handleRecordWin(r);
            if (std.mem.eql(u8, action, "loss")) return handleRecordLoss(r);
            if (std.mem.eql(u8, action, "win-rate")) return handleWinRate(r);
            if (std.mem.eql(u8, action, "verify")) return handleVerify(r);
            if (std.mem.eql(u8, action, "rating")) return handleUpdateRating(r);
        }
    }
    return handleItem(r);
}
