const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/tournament.zig");

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

fn validateTournament(req: m.TournamentCreateRequest) ?[]const u8 {
    if (req.max_players < 2) return "field max_players below minimum";
    if (req.max_players > 512) return "field max_players above maximum";
    // rule: Tournament must allow between 2 and 512 players
    // rule: Entry fee must not be negative
    // rule: Prize pool must not be negative
    // rule: End time must be after start time
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM tournaments WHERE name LIKE '%' || ? || '%' OR description LIKE '%' || ? || '%'", .{q, q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM tournaments", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournaments WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "tournament not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.TournamentCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateTournament(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if (db.exists("SELECT 1 FROM tournaments WHERE public_id = ?", .{req.public_id})) {
        jsonError(r, .conflict, "public_id already exists");
        return;
    }
    const new_id = db.execInsert("INSERT INTO tournaments (public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.public_id, req.name, req.description, req.status, req.bracket_data, req.format, req.tournament_type, req.max_players, req.entry_fee, req.prize_pool, req.start_time, req.end_time, req.is_online, req.location, req.rules_text, req.season_id, req.organizer_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournaments WHERE id = ?", .{new_id}) catch {
        jsonError(r, .internal_server_error, "fetch after insert failed");
        return;
    };
    defer std.heap.page_allocator.free(created_json);
    r.setStatus(.created);
    r.sendJson(created_json) catch {};
}

pub fn handlePut(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.TournamentPutRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const upd = parsed.value;
    db.execUpdate("UPDATE tournaments SET public_id = ?, name = ?, bracket_data = ?, format = ?, tournament_type = ?, max_players = ?, entry_fee = ?, prize_pool = ?, start_time = ?, end_time = ?, is_online = ?, season_id = ?, organizer_id = ?, updated_at = datetime('now') WHERE id = ?", .{upd.public_id, upd.name, upd.bracket_data, upd.format, upd.tournament_type, upd.max_players, upd.entry_fee, upd.prize_pool, upd.start_time, upd.end_time, upd.is_online, upd.season_id, upd.organizer_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournaments WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleUpdate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const patch = std.json.parseFromSlice(m.TournamentUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE tournaments SET public_id = COALESCE(?, public_id), name = COALESCE(?, name), description = COALESCE(?, description), bracket_data = COALESCE(?, bracket_data), format = COALESCE(?, format), tournament_type = COALESCE(?, tournament_type), max_players = COALESCE(?, max_players), entry_fee = COALESCE(?, entry_fee), prize_pool = COALESCE(?, prize_pool), start_time = COALESCE(?, start_time), end_time = COALESCE(?, end_time), is_online = COALESCE(?, is_online), location = COALESCE(?, location), rules_text = COALESCE(?, rules_text), season_id = COALESCE(?, season_id), organizer_id = COALESCE(?, organizer_id), updated_at = datetime('now') WHERE id = ?", .{upd.public_id, upd.name, upd.description, upd.bracket_data, upd.format, upd.tournament_type, upd.max_players, upd.entry_fee, upd.prize_pool, upd.start_time, upd.end_time, upd.is_online, upd.location, upd.rules_text, upd.season_id, upd.organizer_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM tournaments WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: start
pub fn handleStart(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement start
    jsonError(r, .not_implemented, "start not implemented");
}

// behavior: cancel
pub fn handleCancel(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement cancel
    jsonError(r, .not_implemented, "cancel not implemented");
}

// behavior: complete
pub fn handleComplete(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement complete
    jsonError(r, .not_implemented, "complete not implemented");
}

// behavior: generate_round
pub fn handleGenerateRound(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement generate_round
    jsonError(r, .not_implemented, "generate_round not implemented");
}

// behavior: calculate_prize_distribution
pub fn handleCalculatePrizeDistribution(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement calculate_prize_distribution
    jsonError(r, .not_implemented, "calculate_prize_distribution not implemented");
}

// behavior: register_player
pub fn handleRegisterPlayer(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement register_player
    jsonError(r, .not_implemented, "register_player not implemented");
}

// behavior: is_full
pub fn handleIsFull(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement is_full
    jsonError(r, .not_implemented, "is_full not implemented");
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
    if (std.mem.eql(u8, method, "PUT")) return handlePut(r);
    if (std.mem.eql(u8, method, "PATCH")) return handleUpdate(r);
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleAll(r: zap.Request) !void {
    const path = r.path orelse return;
    const prefix = "/api/tournaments";
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
            if (std.mem.eql(u8, action, "start")) return handleStart(r);
            if (std.mem.eql(u8, action, "cancel")) return handleCancel(r);
            if (std.mem.eql(u8, action, "complete")) return handleComplete(r);
            if (std.mem.eql(u8, action, "rounds")) return handleGenerateRound(r);
            if (std.mem.eql(u8, action, "prizes")) return handleCalculatePrizeDistribution(r);
            if (std.mem.eql(u8, action, "register")) return handleRegisterPlayer(r);
            if (std.mem.eql(u8, action, "full")) return handleIsFull(r);
        }
    }
    return handleItem(r);
}
