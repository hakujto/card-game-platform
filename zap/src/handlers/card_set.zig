const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/card_set.zig");

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

fn validateCardSet(req: m.CardSetCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Card set must have at least one card
    // rule: Rotation date must be after release date
    // rule: Rotated set must have a rotation date
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM card_sets WHERE name LIKE '%' || ? || '%' OR code LIKE '%' || ? || '%'", .{q, q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM card_sets", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM card_sets WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "card_set not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.CardSetCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateCardSet(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if (db.exists("SELECT 1 FROM card_sets WHERE code = ?", .{req.code})) {
        jsonError(r, .conflict, "code already exists");
        return;
    }
    const new_id = db.execInsert("INSERT INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.name, req.code, req.release_date, req.rotation_date, req.set_type, req.total_cards, req.is_rotated, req.description, req.logo_url}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM card_sets WHERE id = ?", .{new_id}) catch {
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
    const patch = std.json.parseFromSlice(m.CardSetUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE card_sets SET name = COALESCE(?, name), code = COALESCE(?, code), release_date = COALESCE(?, release_date), rotation_date = COALESCE(?, rotation_date), set_type = COALESCE(?, set_type), total_cards = COALESCE(?, total_cards), is_rotated = COALESCE(?, is_rotated), description = COALESCE(?, description), logo_url = COALESCE(?, logo_url), updated_at = datetime('now') WHERE id = ?", .{upd.name, upd.code, upd.release_date, upd.rotation_date, upd.set_type, upd.total_cards, upd.is_rotated, upd.description, upd.logo_url, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM card_sets WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: is_legal_in_standard
pub fn handleIsLegalInStandard(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement is_legal_in_standard
    jsonError(r, .not_implemented, "is_legal_in_standard not implemented");
}

// behavior: is_legal_in_format
pub fn handleIsLegalInFormat(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement is_legal_in_format
    jsonError(r, .not_implemented, "is_legal_in_format not implemented");
}

// behavior: card_count_by_rarity
pub fn handleCardCountByRarity(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement card_count_by_rarity
    jsonError(r, .not_implemented, "card_count_by_rarity not implemented");
}

// behavior: rotate_out
pub fn handleRotateOut(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement rotate_out
    jsonError(r, .not_implemented, "rotate_out not implemented");
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
    const prefix = "/api/card_sets";
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
            if (std.mem.eql(u8, action, "standard-legal")) return handleIsLegalInStandard(r);
            if (std.mem.eql(u8, action, "legal")) return handleIsLegalInFormat(r);
            if (std.mem.eql(u8, action, "rarity-count")) return handleCardCountByRarity(r);
            if (std.mem.eql(u8, action, "rotate")) return handleRotateOut(r);
        }
    }
    return handleItem(r);
}
