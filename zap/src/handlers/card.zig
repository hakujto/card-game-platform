const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/card.zig");

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

fn validateCard(req: m.CardCreateRequest) ?[]const u8 {
    if (req.mana_cost < 0) return "field mana_cost below minimum";
    if (req.mana_cost > 20) return "field mana_cost above maximum";
    if (req.power_level < 1) return "field power_level below minimum";
    if (req.power_level > 10) return "field power_level above maximum";
    // rule: Creature card must have attack and defense
    // rule: Planeswalker card must have loyalty
    // rule: Land card must have zero mana cost
    // rule: Only Planeswalker cards can have loyalty
    // rule: mana_cost must be between 0 and 20
    // rule: power_level must be between 1 and 10
    // rule: Card cannot be both banned and restricted at the same time
    // rule: Banned card must not appear in any legal formats
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM cards WHERE name LIKE '%' || ? || '%' OR artist_name LIKE '%' || ? || '%'", .{q, q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM cards", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM cards WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "card not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.CardCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateCard(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if ((req.card_type == .creature) and (req.attack == null)) { jsonError(r, .unprocessable_content, "attack is required"); return; }
    if ((req.card_type == .creature) and (req.defense == null)) { jsonError(r, .unprocessable_content, "defense is required"); return; }
    if ((req.card_type == .planeswalker) and (req.loyalty == null)) { jsonError(r, .unprocessable_content, "loyalty is required"); return; }
    if (db.exists("SELECT 1 FROM cards WHERE public_id = ?", .{req.public_id})) {
        jsonError(r, .conflict, "public_id already exists");
        return;
    }
    const new_id = db.execInsert("INSERT INTO cards (public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.public_id, req.name, req.card_type, req.rarity, req.mana_cost, req.mana_colors, req.attack, req.defense, req.loyalty, req.description, req.flavor_text, req.image_url, req.artist_name, req.legal_formats, req.is_banned, req.is_restricted, req.power_level, req.metadata, req.total_copies_in_circulation, req.set_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM cards WHERE id = ?", .{new_id}) catch {
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
    const parsed = std.json.parseFromSlice(m.CardPutRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const upd = parsed.value;
    db.execUpdate("UPDATE cards SET public_id = ?, name = ?, card_type = ?, rarity = ?, mana_cost = ?, mana_colors = ?, attack = ?, defense = ?, loyalty = ?, description = ?, image_url = ?, legal_formats = ?, power_level = ?, metadata = ?, total_copies_in_circulation = ?, set_id = ?, updated_at = datetime('now') WHERE id = ?", .{upd.public_id, upd.name, upd.card_type, upd.rarity, upd.mana_cost, upd.mana_colors, upd.attack, upd.defense, upd.loyalty, upd.description, upd.image_url, upd.legal_formats, upd.power_level, upd.metadata, upd.total_copies_in_circulation, upd.set_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM cards WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleUpdate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const patch = std.json.parseFromSlice(m.CardUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE cards SET public_id = COALESCE(?, public_id), name = COALESCE(?, name), card_type = COALESCE(?, card_type), rarity = COALESCE(?, rarity), mana_cost = COALESCE(?, mana_cost), mana_colors = COALESCE(?, mana_colors), attack = COALESCE(?, attack), defense = COALESCE(?, defense), loyalty = COALESCE(?, loyalty), description = COALESCE(?, description), flavor_text = COALESCE(?, flavor_text), image_url = COALESCE(?, image_url), artist_name = COALESCE(?, artist_name), legal_formats = COALESCE(?, legal_formats), power_level = COALESCE(?, power_level), metadata = COALESCE(?, metadata), total_copies_in_circulation = COALESCE(?, total_copies_in_circulation), set_id = COALESCE(?, set_id), updated_at = datetime('now') WHERE id = ?", .{upd.public_id, upd.name, upd.card_type, upd.rarity, upd.mana_cost, upd.mana_colors, upd.attack, upd.defense, upd.loyalty, upd.description, upd.flavor_text, upd.image_url, upd.artist_name, upd.legal_formats, upd.power_level, upd.metadata, upd.total_copies_in_circulation, upd.set_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM cards WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: ban
pub fn handleBan(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement ban
    jsonError(r, .not_implemented, "ban not implemented");
}

// behavior: unban
pub fn handleUnban(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement unban
    jsonError(r, .not_implemented, "unban not implemented");
}

// behavior: restrict
pub fn handleRestrict(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement restrict
    jsonError(r, .not_implemented, "restrict not implemented");
}

// behavior: unrestrict
pub fn handleUnrestrict(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement unrestrict
    jsonError(r, .not_implemented, "unrestrict not implemented");
}

// behavior: replace
pub fn handleReplace(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement replace
    jsonError(r, .not_implemented, "replace not implemented");
}

// behavior: calculate_value
pub fn handleCalculateValue(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement calculate_value
    jsonError(r, .not_implemented, "calculate_value not implemented");
}

// behavior: apply_rarity_bonus
pub fn handleApplyRarityBonus(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement apply_rarity_bonus
    jsonError(r, .not_implemented, "apply_rarity_bonus not implemented");
}

// behavior: is_legal_in_format
pub fn handleIsLegalInFormat(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement is_legal_in_format
    jsonError(r, .not_implemented, "is_legal_in_format not implemented");
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
    const prefix = "/api/cards";
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
            if (std.mem.eql(u8, action, "ban")) return handleBan(r);
            if (std.mem.eql(u8, action, "unban")) return handleUnban(r);
            if (std.mem.eql(u8, action, "restrict")) return handleRestrict(r);
            if (std.mem.eql(u8, action, "unrestrict")) return handleUnrestrict(r);
            if (std.mem.eql(u8, action, "{id}")) return handleReplace(r);
            if (std.mem.eql(u8, action, "value")) return handleCalculateValue(r);
            if (std.mem.eql(u8, action, "rarity-bonus")) return handleApplyRarityBonus(r);
            if (std.mem.eql(u8, action, "legal")) return handleIsLegalInFormat(r);
        }
    }
    return handleItem(r);
}
