const std = @import("std");

pub const ArticleTagAssignment = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    article_id: i64 = 0,
    tag_id: i64 = 0,
};

pub const ArticleTagAssignmentCreateRequest = struct {
    article_id: i64 = 0,
    tag_id: i64 = 0,
};

pub const ArticleTagAssignmentUpdateRequest = struct {
    article_id: ?i64 = null,
    tag_id: ?i64 = null,
};

pub const ArticleTagAssignmentResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    article_id: i64,
    tag_id: i64,
};
