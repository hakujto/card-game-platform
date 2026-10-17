const std = @import("std");
const c = @import("c");

var _db: ?*c.sqlite3 = null;

pub fn init(path: []const u8) !void {
    var buf: [4096]u8 = undefined;
    const path_z = try std.fmt.bufPrintSentinel(&buf, "{s}", .{path}, 0);
    const rc = c.sqlite3_open_v2(path_z, &_db, c.SQLITE_OPEN_READWRITE | c.SQLITE_OPEN_CREATE | c.SQLITE_OPEN_FULLMUTEX, null);
    if (rc != c.SQLITE_OK) return error.DbOpenFailed;
}

pub fn runMigrations() !void {
    const sql: [*:0]const u8 = @embedFile("migrations/0001_initial.sql").ptr;
    var errmsg: [*c]u8 = null;
    const rc = c.sqlite3_exec(_db, sql, null, null, &errmsg);
    if (rc != c.SQLITE_OK) {
        if (errmsg != null) c.sqlite3_free(errmsg);
        return error.MigrationFailed;
    }
}

fn bindArgs(stmt: *c.sqlite3_stmt, args: anytype) void {
    const ArgsType = @TypeOf(args);
    const info = @typeInfo(ArgsType).@"struct";
    inline for (info.field_names, 1..) |fname, idx| {
        const val = @field(args, fname);
        const T = @TypeOf(val);
        if (T == i64 or T == i32 or T == usize) {
            _ = c.sqlite3_bind_int64(stmt, @intCast(idx), @intCast(val));
        } else if (T == []const u8 or T == []u8) {
            _ = c.sqlite3_bind_text(stmt, @intCast(idx), val.ptr, @intCast(val.len), c.SQLITE_STATIC);
        } else if (T == ?i64 or T == ?i32) {
            if (val) |v| _ = c.sqlite3_bind_int64(stmt, @intCast(idx), @intCast(v))
            else _ = c.sqlite3_bind_null(stmt, @intCast(idx));
        } else if (T == ?[]const u8 or T == ?[]u8) {
            if (val) |v| _ = c.sqlite3_bind_text(stmt, @intCast(idx), v.ptr, @intCast(v.len), c.SQLITE_STATIC)
            else _ = c.sqlite3_bind_null(stmt, @intCast(idx));
        } else if (T == bool) {
            _ = c.sqlite3_bind_int64(stmt, @intCast(idx), if (val) 1 else 0);
        } else if (T == f64 or T == f32) {
            _ = c.sqlite3_bind_double(stmt, @intCast(idx), @floatCast(val));
        } else if (T == ?f64 or T == ?f32) {
            if (val) |v| _ = c.sqlite3_bind_double(stmt, @intCast(idx), @floatCast(v))
            else _ = c.sqlite3_bind_null(stmt, @intCast(idx));
        } else switch (@typeInfo(T)) {
            .@"enum" => {
                const name = @tagName(val);
                _ = c.sqlite3_bind_text(stmt, @intCast(idx), name.ptr, @intCast(name.len), c.SQLITE_STATIC);
            },
            .optional => |opt| switch (@typeInfo(opt.child)) {
                .@"enum" => {
                    if (val) |v| {
                        const name = @tagName(v);
                        _ = c.sqlite3_bind_text(stmt, @intCast(idx), name.ptr, @intCast(name.len), c.SQLITE_STATIC);
                    } else _ = c.sqlite3_bind_null(stmt, @intCast(idx));
                },
                else => _ = c.sqlite3_bind_null(stmt, @intCast(idx)),
            },
            else => {},
        }
    }
}

fn rowToJson(a: std.mem.Allocator, stmt: *c.sqlite3_stmt, buf: *std.ArrayList(u8)) !void {
    const ncols = c.sqlite3_column_count(stmt);
    try buf.append(a, '{');
    var i: c_int = 0;
    while (i < ncols) : (i += 1) {
        if (i > 0) try buf.append(a, ',');
        const name = std.mem.span(c.sqlite3_column_name(stmt, i));
        try buf.append(a, '"');
        try buf.appendSlice(a, name);
        try buf.appendSlice(a, "\":");
        const col_type = c.sqlite3_column_type(stmt, i);
        switch (col_type) {
            c.SQLITE_INTEGER => {
                const v = c.sqlite3_column_int64(stmt, i);
                var tmp: [32]u8 = undefined;
                const s = std.fmt.bufPrint(&tmp, "{d}", .{v}) catch unreachable;
                try buf.appendSlice(a, s);
            },
            c.SQLITE_FLOAT => {
                const v = c.sqlite3_column_double(stmt, i);
                var tmp: [64]u8 = undefined;
                const s = std.fmt.bufPrint(&tmp, "{d}", .{v}) catch unreachable;
                try buf.appendSlice(a, s);
            },
            c.SQLITE_TEXT => {
                const v = std.mem.span(c.sqlite3_column_text(stmt, i));
                try buf.append(a, '"');
                for (v) |ch| {
                    if (ch == '"') try buf.appendSlice(a, "\\\"")
                    else if (ch == '\\') try buf.appendSlice(a, "\\\\")
                    else try buf.append(a, ch);
                }
                try buf.append(a, '"');
            },
            else => try buf.appendSlice(a, "null"),
        }
    }
    try buf.append(a, '}');
}

pub fn queryOneJson(a: std.mem.Allocator, sql: [*:0]const u8, args: anytype) ![]u8 {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(_db, sql, -1, &stmt, null) != c.SQLITE_OK) return error.PrepareFailed;
    defer _ = c.sqlite3_finalize(stmt);
    bindArgs(stmt.?, args);
    const rc = c.sqlite3_step(stmt.?);
    if (rc == c.SQLITE_DONE) return error.NotFound;
    if (rc != c.SQLITE_ROW) return error.QueryFailed;
    var buf: std.ArrayList(u8) = .empty;
    try rowToJson(a, stmt.?, &buf);
    return buf.toOwnedSlice(a);
}

pub fn queryJson(a: std.mem.Allocator, sql: [*:0]const u8, args: anytype) ![]u8 {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(_db, sql, -1, &stmt, null) != c.SQLITE_OK) return error.PrepareFailed;
    defer _ = c.sqlite3_finalize(stmt);
    bindArgs(stmt.?, args);
    var buf: std.ArrayList(u8) = .empty;
    try buf.append(a, '[');
    var first = true;
    while (c.sqlite3_step(stmt.?) == c.SQLITE_ROW) {
        if (!first) try buf.append(a, ',');
        first = false;
        try rowToJson(a, stmt.?, &buf);
    }
    try buf.append(a, ']');
    return buf.toOwnedSlice(a);
}

pub fn execInsert(sql: [*:0]const u8, args: anytype) !i64 {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(_db, sql, -1, &stmt, null) != c.SQLITE_OK) return error.PrepareFailed;
    defer _ = c.sqlite3_finalize(stmt);
    bindArgs(stmt.?, args);
    const rc = c.sqlite3_step(stmt.?);
    if (rc != c.SQLITE_DONE) return error.ExecFailed;
    return c.sqlite3_last_insert_rowid(_db);
}

pub fn execUpdate(sql: [*:0]const u8, args: anytype) !void {
    _ = try execInsert(sql, args);
}

pub fn exists(sql: [*:0]const u8, args: anytype) bool {
    var stmt: ?*c.sqlite3_stmt = null;
    if (c.sqlite3_prepare_v2(_db, sql, -1, &stmt, null) != c.SQLITE_OK) return false;
    defer _ = c.sqlite3_finalize(stmt);
    bindArgs(stmt.?, args);
    return c.sqlite3_step(stmt.?) == c.SQLITE_ROW;
}

pub fn deinit() void {
    if (_db) |d| _ = c.sqlite3_close(d);
    _db = null;
}
