const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/tournament_prize.zig");

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

fn validateTournamentPrize(req: m.TournamentPrizeCreateRequest) ?[]const u8 {
    if (req.placement_from < 1) return "field placement_from below minimum";
    if (req.placement_to < 1) return "field placement_to below minimum";
    // rule: placement_to must be greater than or equal to placement_from
    // rule: placement_from must be greater than zero
    // rule: Prize amount must not be negative
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const rows_json = db.queryJson(std.heap.page_allocator, "SELECT * FROM tournament_prizes", .{}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournament_prizes WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "tournament_prize not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.TournamentPrizeCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateTournamentPrize(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    const new_id = db.execInsert("INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", .{req.placement_from, req.placement_to, req.prize_type, req.amount, req.description, req.packs_count, req.season_points, req.tournament_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournament_prizes WHERE id = ?", .{new_id}) catch {
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
    const patch = std.json.parseFromSlice(m.TournamentPrizeUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE tournament_prizes SET placement_from = COALESCE(?, placement_from), placement_to = COALESCE(?, placement_to), prize_type = COALESCE(?, prize_type), amount = COALESCE(?, amount), description = COALESCE(?, description), packs_count = COALESCE(?, packs_count), season_points = COALESCE(?, season_points), tournament_id = COALESCE(?, tournament_id), updated_at = datetime('now') WHERE id = ?", .{upd.placement_from, upd.placement_to, upd.prize_type, upd.amount, upd.description, upd.packs_count, upd.season_points, upd.tournament_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournament_prizes WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleDelete(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    db.execUpdate("DELETE FROM tournament_prizes WHERE id = ?", .{id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    r.setStatus(.no_content);
    r.sendBody("") catch {};
}

// behavior: applies_to_placement
pub fn handleAppliesToPlacement(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement applies_to_placement
    jsonError(r, .not_implemented, "applies_to_placement not implemented");
}

// behavior: award_to_player
pub fn handleAwardToPlayer(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement award_to_player
    jsonError(r, .not_implemented, "award_to_player not implemented");
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
    if (std.mem.eql(u8, method, "DELETE")) return handleDelete(r);
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleAll(r: zap.Request) !void {
    const path = r.path orelse return;
    const prefix = "/api/tournament_prizes";
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
            if (std.mem.eql(u8, action, "applies")) return handleAppliesToPlacement(r);
            if (std.mem.eql(u8, action, "award")) return handleAwardToPlayer(r);
        }
    }
    return handleItem(r);
}
