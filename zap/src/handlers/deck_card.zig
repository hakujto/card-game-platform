const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/deck_card.zig");

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

fn validateDeckCard(req: m.DeckCardCreateRequest) ?[]const u8 {
    if (req.quantity < 1) return "field quantity below minimum";
    if (req.quantity > 4) return "field quantity above maximum";
    // rule: A deck can contain between 1 and 4 copies of a card
    // rule: Commander card must appear exactly once in the deck
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const rows_json = db.queryJson(std.heap.page_allocator, "SELECT * FROM deck_cards", .{}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM deck_cards WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "deck_card not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.DeckCardCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateDeckCard(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    const new_id = db.execInsert("INSERT INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (?, ?, ?, ?)", .{req.quantity, req.is_commander, req.deck_id, req.card_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM deck_cards WHERE id = ?", .{new_id}) catch {
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
    const patch = std.json.parseFromSlice(m.DeckCardUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE deck_cards SET quantity = COALESCE(?, quantity), is_commander = COALESCE(?, is_commander), deck_id = COALESCE(?, deck_id), card_id = COALESCE(?, card_id), updated_at = datetime('now') WHERE id = ?", .{upd.quantity, upd.is_commander, upd.deck_id, upd.card_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM deck_cards WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleDelete(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    db.execUpdate("DELETE FROM deck_cards WHERE id = ?", .{id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    r.setStatus(.no_content);
    r.sendBody("") catch {};
}

// behavior: increment
pub fn handleIncrement(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement increment
    jsonError(r, .not_implemented, "increment not implemented");
}

// behavior: decrement
pub fn handleDecrement(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement decrement
    jsonError(r, .not_implemented, "decrement not implemented");
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
    const prefix = "/api/deck_cards";
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
            if (std.mem.eql(u8, action, "increment")) return handleIncrement(r);
            if (std.mem.eql(u8, action, "decrement")) return handleDecrement(r);
        }
    }
    return handleItem(r);
}
