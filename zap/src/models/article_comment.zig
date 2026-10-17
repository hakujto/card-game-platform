const std = @import("std");

pub const ArticleComment = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    body: []const u8 = "",
    is_hidden: bool = false,
    article_id: i64 = 0,
    author_id: i64 = 0,
    parent_comment_id: ?i64 = null,
};

pub const ArticleCommentCreateRequest = struct {
    body: []const u8 = "",
    is_hidden: bool = false,
    article_id: i64 = 0,
    author_id: i64 = 0,
    parent_comment_id: ?i64 = null,
};

pub const ArticleCommentUpdateRequest = struct {
    body: ?[]const u8 = null,
    is_hidden: ?bool = null,
    article_id: ?i64 = null,
    author_id: ?i64 = null,
    parent_comment_id: ?i64 = null,
};

pub const ArticleCommentResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    body: []const u8,
    is_hidden: bool,
    article_id: i64,
    author_id: i64,
    parent_comment_id: ?i64,
};
