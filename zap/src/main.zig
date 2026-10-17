const std = @import("std");
const zap = @import("zap");
const db  = @import("db.zig");

const card_handler = @import("handlers/card.zig");
const card_set_handler = @import("handlers/card_set.zig");
const card_ruling_handler = @import("handlers/card_ruling.zig");
const card_ability_handler = @import("handlers/card_ability.zig");
const deck_handler = @import("handlers/deck.zig");
const deck_card_handler = @import("handlers/deck_card.zig");
const deck_sideboard_card_handler = @import("handlers/deck_sideboard_card.zig");
const deck_tag_handler = @import("handlers/deck_tag.zig");
const deck_tag_assignment_handler = @import("handlers/deck_tag_assignment.zig");
const player_handler = @import("handlers/player.zig");
const player_season_stats_handler = @import("handlers/player_season_stats.zig");
const player_collection_handler = @import("handlers/player_collection.zig");
const friendship_handler = @import("handlers/friendship.zig");
const achievement_handler = @import("handlers/achievement.zig");
const player_achievement_handler = @import("handlers/player_achievement.zig");
const crafting_recipe_handler = @import("handlers/crafting_recipe.zig");
const crafting_ingredient_handler = @import("handlers/crafting_ingredient.zig");
const season_handler = @import("handlers/season.zig");
const tournament_handler = @import("handlers/tournament.zig");
const tournament_judge_handler = @import("handlers/tournament_judge.zig");
const tournament_registration_handler = @import("handlers/tournament_registration.zig");
const tournament_round_handler = @import("handlers/tournament_round.zig");
const match_handler = @import("handlers/match.zig");
const game_handler = @import("handlers/game.zig");
const tournament_prize_handler = @import("handlers/tournament_prize.zig");
const awarded_prize_handler = @import("handlers/awarded_prize.zig");
const product_handler = @import("handlers/product.zig");
const order_handler = @import("handlers/order.zig");
const order_item_handler = @import("handlers/order_item.zig");
const coupon_handler = @import("handlers/coupon.zig");
const trade_listing_handler = @import("handlers/trade_listing.zig");
const trade_bid_handler = @import("handlers/trade_bid.zig");
const trade_transaction_handler = @import("handlers/trade_transaction.zig");
const card_price_history_handler = @import("handlers/card_price_history.zig");
const trade_dispute_handler = @import("handlers/trade_dispute.zig");
const draft_session_handler = @import("handlers/draft_session.zig");
const draft_participant_handler = @import("handlers/draft_participant.zig");
const draft_pick_handler = @import("handlers/draft_pick.zig");
const article_handler = @import("handlers/article.zig");
const article_tag_handler = @import("handlers/article_tag.zig");
const article_tag_assignment_handler = @import("handlers/article_tag_assignment.zig");
const article_comment_handler = @import("handlers/article_comment.zig");
const stream_handler = @import("handlers/stream.zig");

fn getenv(name: [*:0]const u8) ?[:0]const u8 {
    const ptr = std.c.getenv(name) orelse return null;
    return std.mem.span(ptr);
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const db_path = getenv("DATABASE_URL") orelse "app.db";
    try db.init(db_path);
    defer db.deinit();
    try db.runMigrations();

    const port_str = getenv("PORT") orelse "8080";
    const port = try std.fmt.parseInt(u16, port_str, 10);

    var router = zap.Router.init(allocator, .{ .not_found = notFound });
    defer router.deinit();

    try router.handle_func_unbound("/api/cards", card_handler.handleAll);
    try router.handle_func_unbound("/api/card_sets", card_set_handler.handleAll);
    try router.handle_func_unbound("/api/card_rulings", card_ruling_handler.handleAll);
    try router.handle_func_unbound("/api/card_abilities", card_ability_handler.handleAll);
    try router.handle_func_unbound("/api/decks", deck_handler.handleAll);
    try router.handle_func_unbound("/api/deck_cards", deck_card_handler.handleAll);
    try router.handle_func_unbound("/api/deck_sideboard_cards", deck_sideboard_card_handler.handleAll);
    try router.handle_func_unbound("/api/deck_tags", deck_tag_handler.handleAll);
    try router.handle_func_unbound("/api/deck_tag_assignments", deck_tag_assignment_handler.handleAll);
    try router.handle_func_unbound("/api/players", player_handler.handleAll);
    try router.handle_func_unbound("/api/player_season_statses", player_season_stats_handler.handleAll);
    try router.handle_func_unbound("/api/player_collections", player_collection_handler.handleAll);
    try router.handle_func_unbound("/api/friendships", friendship_handler.handleAll);
    try router.handle_func_unbound("/api/achievements", achievement_handler.handleAll);
    try router.handle_func_unbound("/api/player_achievements", player_achievement_handler.handleAll);
    try router.handle_func_unbound("/api/crafting_recipes", crafting_recipe_handler.handleAll);
    try router.handle_func_unbound("/api/crafting_ingredients", crafting_ingredient_handler.handleAll);
    try router.handle_func_unbound("/api/seasons", season_handler.handleAll);
    try router.handle_func_unbound("/api/tournaments", tournament_handler.handleAll);
    try router.handle_func_unbound("/api/tournament_judges", tournament_judge_handler.handleAll);
    try router.handle_func_unbound("/api/tournament_registrations", tournament_registration_handler.handleAll);
    try router.handle_func_unbound("/api/tournament_rounds", tournament_round_handler.handleAll);
    try router.handle_func_unbound("/api/matches", match_handler.handleAll);
    try router.handle_func_unbound("/api/games", game_handler.handleAll);
    try router.handle_func_unbound("/api/tournament_prizes", tournament_prize_handler.handleAll);
    try router.handle_func_unbound("/api/awarded_prizes", awarded_prize_handler.handleAll);
    try router.handle_func_unbound("/api/products", product_handler.handleAll);
    try router.handle_func_unbound("/api/orders", order_handler.handleAll);
    try router.handle_func_unbound("/api/order_items", order_item_handler.handleAll);
    try router.handle_func_unbound("/api/coupons", coupon_handler.handleAll);
    try router.handle_func_unbound("/api/trade_listings", trade_listing_handler.handleAll);
    try router.handle_func_unbound("/api/trade_bids", trade_bid_handler.handleAll);
    try router.handle_func_unbound("/api/trade_transactions", trade_transaction_handler.handleAll);
    try router.handle_func_unbound("/api/card_price_histories", card_price_history_handler.handleAll);
    try router.handle_func_unbound("/api/trade_disputes", trade_dispute_handler.handleAll);
    try router.handle_func_unbound("/api/draft_sessions", draft_session_handler.handleAll);
    try router.handle_func_unbound("/api/draft_participants", draft_participant_handler.handleAll);
    try router.handle_func_unbound("/api/draft_picks", draft_pick_handler.handleAll);
    try router.handle_func_unbound("/api/articles", article_handler.handleAll);
    try router.handle_func_unbound("/api/article_tags", article_tag_handler.handleAll);
    try router.handle_func_unbound("/api/article_tag_assignments", article_tag_assignment_handler.handleAll);
    try router.handle_func_unbound("/api/article_comments", article_comment_handler.handleAll);
    try router.handle_func_unbound("/api/streams", stream_handler.handleAll);

    var listener = zap.HttpListener.init(.{
        .port = port,
        .on_request = router.on_request_handler(),
        .log = true,
        .public_folder = null,
    });
    try listener.listen();

    std.debug.print("Listening on :{d}\n", .{port});
    zap.start(.{ .threads = 2, .workers = 1 });
}

fn notFound(r: zap.Request) !void {
    r.setStatus(.not_found);
    try r.sendJson("{\"error\":\"not found\"}");
}
