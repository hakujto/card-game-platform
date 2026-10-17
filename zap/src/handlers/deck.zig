const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/deck.zig");

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

fn validateDeck(req: m.DeckCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Deck wins count must not be negative
    // rule: Deck losses count must not be negative
    // rule: Deck draws count must not be negative
    // rule: Tournament-legal deck must be made public
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM decks WHERE name LIKE '%' || ? || '%' OR description LIKE '%' || ? || '%'", .{q, q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM decks", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM decks WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "deck not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.DeckCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateDeck(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    const new_id = db.execInsert("INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.name, req.description, req.format, req.is_public, req.is_tournament_legal, req.archetype, req.wins, req.losses, req.draws, req.player_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    // hook: after save — recalculate_tournament_legal
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM decks WHERE id = ?", .{new_id}) catch {
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
    const parsed = std.json.parseFromSlice(m.DeckPutRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const upd = parsed.value;
    db.execUpdate("UPDATE decks SET format = ?, is_public = ?, is_tournament_legal = ?, player_id = ?, updated_at = datetime('now') WHERE id = ?", .{upd.format, upd.is_public, upd.is_tournament_legal, upd.player_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM decks WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleUpdate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const patch = std.json.parseFromSlice(m.DeckUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE decks SET name = COALESCE(?, name), description = COALESCE(?, description), format = COALESCE(?, format), is_public = COALESCE(?, is_public), is_tournament_legal = COALESCE(?, is_tournament_legal), archetype = COALESCE(?, archetype), player_id = COALESCE(?, player_id), updated_at = datetime('now') WHERE id = ?", .{upd.name, upd.description, upd.format, upd.is_public, upd.is_tournament_legal, upd.archetype, upd.player_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM decks WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleDelete(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    db.execUpdate("DELETE FROM decks WHERE id = ?", .{id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    r.setStatus(.no_content);
    r.sendBody("") catch {};
}

// behavior: validate_size
pub fn handleValidateSize(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement validate_size
    jsonError(r, .not_implemented, "validate_size not implemented");
}

// behavior: add_card
pub fn handleAddCard(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement add_card
    jsonError(r, .not_implemented, "add_card not implemented");
}

// behavior: remove_card
pub fn handleRemoveCard(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement remove_card
    jsonError(r, .not_implemented, "remove_card not implemented");
}

// behavior: win_rate
pub fn handleWinRate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement win_rate
    jsonError(r, .not_implemented, "win_rate not implemented");
}

// behavior: clone
pub fn handleClone(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement clone
    jsonError(r, .not_implemented, "clone not implemented");
}

// behavior: publish
pub fn handlePublish(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement publish
    jsonError(r, .not_implemented, "publish not implemented");
}

// behavior: unpublish
pub fn handleUnpublish(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement unpublish
    jsonError(r, .not_implemented, "unpublish not implemented");
}

// behavior: certify_tournament_legal
pub fn handleCertifyTournamentLegal(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement certify_tournament_legal
    jsonError(r, .not_implemented, "certify_tournament_legal not implemented");
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
    if (std.mem.eql(u8, method, "DELETE")) return handleDelete(r);
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleAll(r: zap.Request) !void {
    const path = r.path orelse return;
    const prefix = "/api/decks";
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
            if (std.mem.eql(u8, action, "validate")) return handleValidateSize(r);
            if (std.mem.eql(u8, action, "cards")) return handleAddCard(r);
            if (std.mem.eql(u8, action, "{card_id}")) return handleRemoveCard(r);
            if (std.mem.eql(u8, action, "win-rate")) return handleWinRate(r);
            if (std.mem.eql(u8, action, "clone")) return handleClone(r);
            if (std.mem.eql(u8, action, "publish")) return handlePublish(r);
            if (std.mem.eql(u8, action, "unpublish")) return handleUnpublish(r);
            if (std.mem.eql(u8, action, "certify")) return handleCertifyTournamentLegal(r);
        }
    }
    return handleItem(r);
}
