const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/trade_transaction.zig");

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

fn validateTradeTransaction(req: m.TradeTransactionCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Platform fee cannot exceed the final price
    // rule: Platform fee must not be negative
    // rule: Transaction final price must be greater than zero
    // rule: Completed transaction must have a completed_at timestamp
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const rows_json = db.queryJson(std.heap.page_allocator, "SELECT * FROM trade_transactions", .{}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM trade_transactions WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "trade_transaction not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

// behavior: complete
pub fn handleComplete(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement complete
    jsonError(r, .not_implemented, "complete not implemented");
}

// behavior: refund
pub fn handleRefund(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement refund
    jsonError(r, .not_implemented, "refund not implemented");
}

// behavior: open_dispute
pub fn handleOpenDispute(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement open_dispute
    jsonError(r, .not_implemented, "open_dispute not implemented");
}

// behavior: seller_net
pub fn handleSellerNet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement seller_net
    jsonError(r, .not_implemented, "seller_net not implemented");
}

pub fn handleCollection(r: zap.Request) !void {
    const method = r.method orelse return;
    if (std.mem.eql(u8, method, "GET")) return handleList(r);
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
    const prefix = "/api/trade_transactions";
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
            if (std.mem.eql(u8, action, "complete")) return handleComplete(r);
            if (std.mem.eql(u8, action, "refund")) return handleRefund(r);
            if (std.mem.eql(u8, action, "dispute")) return handleOpenDispute(r);
            if (std.mem.eql(u8, action, "seller-net")) return handleSellerNet(r);
        }
    }
    return handleItem(r);
}
