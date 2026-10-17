const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/order.zig");

fn getRequestUserId(r: zap.Request) ?i64 {
    if (r.getHeader("x-user-id")) |uid| {
        return std.fmt.parseInt(i64, uid, 10) catch null;
    }
    return null;
}

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

fn validateOrder(req: m.OrderCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Paid order must have paid_at set
    // rule: Shipped order must have a tracking number
    // rule: shipped_at_requires_shipped_status
    // rule: Order total must not be negative
    // rule: Discount applied cannot exceed order total
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const rows_json = db.queryJson(std.heap.page_allocator, "SELECT * FROM orders", .{}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM orders WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "order not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.OrderCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateOrder(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if ((req.status == .shipped) and (req.tracking_number == null)) { jsonError(r, .unprocessable_content, "tracking_number is required"); return; }
    if ((req.status == .paid) and (req.paid_at == null)) { jsonError(r, .unprocessable_content, "paid_at is required"); return; }
    const new_id = db.execInsert("INSERT INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.status, req.total, req.discount_applied, req.currency, req.payment_method, req.payment_reference, req.shipping_address, req.tracking_number, req.paid_at, req.shipped_at, req.player_id, req.coupon_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM orders WHERE id = ?", .{new_id}) catch {
        jsonError(r, .internal_server_error, "fetch after insert failed");
        return;
    };
    defer std.heap.page_allocator.free(created_json);
    r.setStatus(.created);
    r.sendJson(created_json) catch {};
}

// behavior: cancel
pub fn handleCancel(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement cancel
    jsonError(r, .not_implemented, "cancel not implemented");
}

// behavior: pay
pub fn handlePay(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // guard: {"type":"eq","field":"status","value":"Pending"}
    // TODO: implement pay
    jsonError(r, .not_implemented, "pay not implemented");
}

// behavior: process_payment
pub fn handleProcessPayment(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement process_payment
    jsonError(r, .not_implemented, "process_payment not implemented");
}

// behavior: calculate_total
pub fn handleCalculateTotal(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement calculate_total
    jsonError(r, .not_implemented, "calculate_total not implemented");
}

// behavior: apply_discount
pub fn handleApplyDiscount(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement apply_discount
    jsonError(r, .not_implemented, "apply_discount not implemented");
}

// behavior: refund
pub fn handleRefund(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement refund
    jsonError(r, .not_implemented, "refund not implemented");
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
    r.setStatus(.method_not_allowed);
    r.sendBody("") catch {};
}

pub fn handleAll(r: zap.Request) !void {
    const path = r.path orelse return;
    const prefix = "/api/orders";
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
            if (std.mem.eql(u8, action, "cancel")) return handleCancel(r);
            if (std.mem.eql(u8, action, "pay")) return handlePay(r);
            if (std.mem.eql(u8, action, "process-payment")) return handleProcessPayment(r);
            if (std.mem.eql(u8, action, "total")) return handleCalculateTotal(r);
            if (std.mem.eql(u8, action, "discount")) return handleApplyDiscount(r);
            if (std.mem.eql(u8, action, "refund")) return handleRefund(r);
        }
    }
    return handleItem(r);
}
