const std = @import("std");
const zap = @import("zap");
const db  = @import("../db.zig");
const m   = @import("../models/article.zig");

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

fn validateArticle(req: m.ArticleCreateRequest) ?[]const u8 {
    _ = req;
    // rule: Published article must have a published_at timestamp
    // rule: Article view count must not be negative
    // rule: Article likes count must not be negative
    return null;
}

pub fn handleList(r: zap.Request) !void {
    const q = r.getParamSlice("q") orelse "";
    const rows_json = if (q.len > 0)
        db.queryJson(std.heap.page_allocator, "SELECT * FROM articles WHERE title LIKE '%' || ? || '%' OR excerpt LIKE '%' || ? || '%'", .{q, q}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        }
    else
        db.queryJson(std.heap.page_allocator, "SELECT * FROM articles", .{}) catch |err| {
            jsonError(r, .internal_server_error, @errorName(err));
            return;
        };
    defer std.heap.page_allocator.free(rows_json);
    r.setStatus(.ok);
    r.sendJson(rows_json) catch {};
}

pub fn handleGet(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const row_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM articles WHERE id = ?", .{id}) catch |err| {
        if (err == error.NotFound) { jsonError(r, .not_found, "article not found"); return; }
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    defer std.heap.page_allocator.free(row_json);
    r.setStatus(.ok);
    r.sendJson(row_json) catch {};
}

pub fn handleCreate(r: zap.Request) !void {
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const parsed = std.json.parseFromSlice(m.ArticleCreateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const req = parsed.value;
    if (validateArticle(req)) |err_msg| { jsonError(r, .unprocessable_content, err_msg); return; }
    if (db.exists("SELECT 1 FROM articles WHERE slug = ?", .{req.slug})) {
        jsonError(r, .conflict, "slug already exists");
        return;
    }
    const new_id = db.execInsert("INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", .{req.title, req.slug, req.body, req.excerpt, req.cover_image_url, req.status, req.article_type, req.language, req.view_count, req.likes_count, req.total_views_alltime, req.is_featured, req.published_at, req.author_id, req.featured_deck_id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    // hook: after save — update_search_index
    const created_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM articles WHERE id = ?", .{new_id}) catch {
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
    const parsed = std.json.parseFromSlice(m.ArticlePutRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer parsed.deinit();
    const upd = parsed.value;
    db.execUpdate("UPDATE articles SET title = ?, slug = ?, body = ?, article_type = ?, language = ?, total_views_alltime = ?, published_at = ?, author_id = ?, featured_deck_id = ?, updated_at = datetime('now') WHERE id = ?", .{upd.title, upd.slug, upd.body, upd.article_type, upd.language, upd.total_views_alltime, upd.published_at, upd.author_id, upd.featured_deck_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM articles WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

pub fn handleUpdate(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    const body = r.body orelse { jsonError(r, .bad_request, "missing body"); return; };
    const patch = std.json.parseFromSlice(m.ArticleUpdateRequest, std.heap.page_allocator, body, .{ .ignore_unknown_fields = true }) catch {
        jsonError(r, .bad_request, "invalid JSON");
        return;
    };
    defer patch.deinit();
    const upd = patch.value;
    db.execUpdate("UPDATE articles SET title = COALESCE(?, title), slug = COALESCE(?, slug), body = COALESCE(?, body), excerpt = COALESCE(?, excerpt), cover_image_url = COALESCE(?, cover_image_url), article_type = COALESCE(?, article_type), language = COALESCE(?, language), total_views_alltime = COALESCE(?, total_views_alltime), is_featured = COALESCE(?, is_featured), published_at = COALESCE(?, published_at), author_id = COALESCE(?, author_id), featured_deck_id = COALESCE(?, featured_deck_id), updated_at = datetime('now') WHERE id = ?", .{upd.title, upd.slug, upd.body, upd.excerpt, upd.cover_image_url, upd.article_type, upd.language, upd.total_views_alltime, upd.is_featured, upd.published_at, upd.author_id, upd.featured_deck_id, id}) catch |err| {
        jsonError(r, .internal_server_error, @errorName(err));
        return;
    };
    const updated_json = db.queryOneJson(std.heap.page_allocator, "SELECT * FROM articles WHERE id = ?", .{id}) catch {
        jsonError(r, .internal_server_error, "fetch after update failed"); return;
    };
    defer std.heap.page_allocator.free(updated_json);
    r.setStatus(.ok);
    r.sendJson(updated_json) catch {};
}

// behavior: publish
pub fn handlePublish(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement publish
    jsonError(r, .not_implemented, "publish not implemented");
}

// behavior: archive
pub fn handleArchive(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement archive
    jsonError(r, .not_implemented, "archive not implemented");
}

// behavior: replace
pub fn handleReplace(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement replace
    jsonError(r, .not_implemented, "replace not implemented");
}

// behavior: increment_view
pub fn handleIncrementView(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement increment_view
    jsonError(r, .not_implemented, "increment_view not implemented");
}

// behavior: like
pub fn handleLike(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement like
    jsonError(r, .not_implemented, "like not implemented");
}

// behavior: unlike
pub fn handleUnlike(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement unlike
    jsonError(r, .not_implemented, "unlike not implemented");
}

// behavior: reading_time_minutes
pub fn handleReadingTimeMinutes(r: zap.Request) !void {
    const id = parseId(r) catch { jsonError(r, .bad_request, "invalid id"); return; };
    _ = id;
    // TODO: implement reading_time_minutes
    jsonError(r, .not_implemented, "reading_time_minutes not implemented");
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
    const prefix = "/api/articles";
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
            if (std.mem.eql(u8, action, "publish")) return handlePublish(r);
            if (std.mem.eql(u8, action, "archive")) return handleArchive(r);
            if (std.mem.eql(u8, action, "{id}")) return handleReplace(r);
            if (std.mem.eql(u8, action, "view")) return handleIncrementView(r);
            if (std.mem.eql(u8, action, "like")) return handleLike(r);
            if (std.mem.eql(u8, action, "like")) return handleUnlike(r);
            if (std.mem.eql(u8, action, "reading-time")) return handleReadingTimeMinutes(r);
        }
    }
    return handleItem(r);
}
