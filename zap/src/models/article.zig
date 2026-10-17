const std = @import("std");

pub const ArticleStatus = enum {
    draft,
    published,
    archived,
};

pub const ArticleArticleType = enum {
    guide,
    tierlist,
    matchup,
    news,
    spotlight,
    decklist,
};

pub const ArticleLanguage = enum {
    e_n,
    d_e,
    f_r,
    i_t,
    e_s,
    j_p,
    p_t,
};

pub const Article = struct {
    id: i64 = 0,
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    title: []const u8 = "",
    slug: []const u8 = "",
    body: []const u8 = "",
    excerpt: ?[]const u8 = null,
    cover_image_url: ?[]const u8 = null,
    status: ArticleStatus = .draft,
    article_type: ArticleArticleType = .guide,
    language: ArticleLanguage = .e_n,
    view_count: i64 = 0,
    likes_count: i64 = 0,
    total_views_alltime: i64 = 0,
    is_featured: bool = false,
    published_at: ?[]const u8 = null,
    author_id: i64 = 0,
    featured_deck_id: ?i64 = null,
};

pub const ArticleCreateRequest = struct {
    title: []const u8 = "",
    slug: []const u8 = "",
    body: []const u8 = "",
    excerpt: ?[]const u8 = null,
    cover_image_url: ?[]const u8 = null,
    status: ArticleStatus = .draft,
    article_type: ArticleArticleType = .guide,
    language: ArticleLanguage = .e_n,
    view_count: i64 = 0,
    likes_count: i64 = 0,
    total_views_alltime: i64 = 0,
    is_featured: bool = false,
    published_at: ?[]const u8 = null,
    author_id: i64 = 0,
    featured_deck_id: ?i64 = null,
};

pub const ArticleUpdateRequest = struct {
    title: ?[]const u8 = null,
    slug: ?[]const u8 = null,
    body: ?[]const u8 = null,
    excerpt: ?[]const u8 = null,
    cover_image_url: ?[]const u8 = null,
    article_type: ?ArticleArticleType = null,
    language: ?ArticleLanguage = null,
    total_views_alltime: ?i64 = null,
    is_featured: ?bool = null,
    published_at: ?[]const u8 = null,
    author_id: ?i64 = null,
    featured_deck_id: ?i64 = null,
};

pub const ArticlePutRequest = struct {
    title: ?[]const u8 = null,
    slug: ?[]const u8 = null,
    body: ?[]const u8 = null,
    article_type: ?ArticleArticleType = null,
    language: ?ArticleLanguage = null,
    total_views_alltime: ?i64 = null,
    published_at: ?[]const u8 = null,
    author_id: ?i64 = null,
    featured_deck_id: ?i64 = null,
};

pub const ArticleResponse = struct {
    id: i64,
    created_at: []const u8,
    updated_at: []const u8,
    title: []const u8,
    slug: []const u8,
    body: []const u8,
    excerpt: ?[]const u8,
    cover_image_url: ?[]const u8,
    status: ArticleStatus,
    article_type: ArticleArticleType,
    language: ArticleLanguage,
    view_count: i64,
    likes_count: i64,
    total_views_alltime: i64,
    is_featured: bool,
    publishedAt: ?[]const u8,
    author_id: i64,
    featured_deck_id: ?i64,
};

// Lifecycle state machine for Article
pub fn allowedTransition(from: []const u8, to: []const u8) bool {
    if (std.mem.eql(u8, from, "Draft") and std.mem.eql(u8, to, "Published")) return true;
    if (std.mem.eql(u8, from, "Published") and std.mem.eql(u8, to, "Archived")) return true;
    if (std.mem.eql(u8, from, "Archived") and std.mem.eql(u8, to, "Draft")) return true;
    return false;
}
