const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/trade_listing.zig");

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

fn validateTradeListing(req: m.TradeListingCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Fixed price listing must have an asking price
    // rule: Auction listing must have a start price and end time
    // rule: Listing quantity must be between 1 and 9999
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM trade_listings WHERE description LIKE '%' || ? || '%'", .{q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM trade_listings", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM trade_listings WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "trade_listing not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.TradeListingCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateTradeListing(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if ((req.listing_type == .fixed_price) and (req.asking_price == null)) { jsonError(r, .unprocessable_content, "asking_price is required"); return; }
    if (db.exists("SELECT 1 FROM trade_listings WHERE public_id = ?", .{req.public_id})) {
        jsonError(r, .conflict, "public_id already exists");
        return;
    }
    const new_id = db.execInsert("INSERT INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.public_id, req.status, req.listing_type, req.asking_price, req.auction_start_price, req.auction_current_bid, req.auction_end_time, req.foil, req.condition, req.quantity, req.description, req.expires_at, req.seller_id, req.card_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM trade_listings WHERE id = ?", .{new_id}) catch {
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
    const patch = std.json.parseFromSlice(m.TradeListingUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE trade_listings SET public_id = COALESCE(?, public_id), listing_type = COALESCE(?, listing_type), asking_price = COALESCE(?, asking_price), auction_start_price = COALESCE(?, auction_start_price), auction_current_bid = COALESCE(?, auction_current_bid), auction_end_time = COALESCE(?, auction_end_time), foil = COALESCE(?, foil), condition = COALESCE(?, condition), quantity = COALESCE(?, quantity), description = COALESCE(?, description), expires_at = COALESCE(?, expires_at), seller_id = COALESCE(?, seller_id), card_id = COALESCE(?, card_id), updated_at = datetime('now') WHERE id = ?", .{upd.public_id, upd.listing_type, upd.asking_price, upd.auction_start_price, upd.auction_current_bid, upd.auction_end_time, upd.foil, upd.condition, upd.quantity, upd.description, upd.expires_at, upd.seller_id, upd.card_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM trade_listings WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: close
pub fn handleClose(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement close
    jsonError(r, .not_implemented, "close not implemented");
}

// behavior: extend
pub fn handleExtend(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement extend
    jsonError(r, .not_implemented, "extend not implemented");
}

// behavior: cancel
pub fn handleCancel(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // guard: {"type":"eq","field":"status","value":"Active"}
    // TODO: implement cancel
    jsonError(r, .not_implemented, "cancel not implemented");
}

// behavior: is_expired
pub fn handleIsExpired(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement is_expired
    jsonError(r, .not_implemented, "is_expired not implemented");
}

// behavior: finalize_auction
pub fn handleFinalizeAuction(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // on: status
    // TODO: implement finalize_auction
    jsonError(r, .not_implemented, "finalize_auction not implemented");
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
    const prefix = "/api/trade_listings";
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
            if (std.mem.eql(u8, action, "close")) return handleClose(r);
            if (std.mem.eql(u8, action, "extend")) return handleExtend(r);
            if (std.mem.eql(u8, action, "cancel")) return handleCancel(r);
            if (std.mem.eql(u8, action, "expired")) return handleIsExpired(r);
            if (std.mem.eql(u8, action, "finalize")) return handleFinalizeAuction(r);
        }
    }
    return handleItem(r);
}
