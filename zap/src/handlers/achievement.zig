const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/achievement.zig");

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

fn validateAchievement(req: m.AchievementCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Achievement must award at least one point
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM achievements WHERE name LIKE '%' || ? || '%' OR description LIKE '%' || ? || '%'", .{q, q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM achievements", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM achievements WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "achievement not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.AchievementCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateAchievement(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    const new_id = db.execInsert("INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES (?, ?, ?, ?, ?, ?)", .{req.name, req.description, req.icon_url, req.points, req.rarity, req.is_hidden}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM achievements WHERE id = ?", .{new_id}) catch {
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
    const patch = std.json.parseFromSlice(m.AchievementUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE achievements SET name = COALESCE(?, name), description = COALESCE(?, description), icon_url = COALESCE(?, icon_url), points = COALESCE(?, points), rarity = COALESCE(?, rarity), is_hidden = COALESCE(?, is_hidden), updated_at = datetime('now') WHERE id = ?", .{upd.name, upd.description, upd.icon_url, upd.points, upd.rarity, upd.is_hidden, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM achievements WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: point_value
pub fn handlePointValue(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement point_value
    jsonError(r, .not_implemented, "point_value not implemented");
}

// behavior: reveal
pub fn handleReveal(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement reveal
    jsonError(r, .not_implemented, "reveal not implemented");
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
    const prefix = "/api/achievements";
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
            if (std.mem.eql(u8, action, "point-value")) return handlePointValue(r);
            if (std.mem.eql(u8, action, "reveal")) return handleReveal(r);
        }
    }
    return handleItem(r);
}
