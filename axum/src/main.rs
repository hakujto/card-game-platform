use axum::Router;
use sqlx::SqlitePool;
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;

mod handlers;
mod models;
mod serde_utils;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let database_url = std::env::var("DATABASE_URL").unwrap_or_else(|_| "sqlite:app.db".to_string());
    let pool = SqlitePool::connect(&database_url).await.expect("Failed to connect to database");

    sqlx::migrate!("./migrations").run(&pool).await.expect("Migration failed");

    let app = Router::new()
        .merge(handlers::cards::card::card_router())
        .merge(handlers::cards::card_set::card_set_router())
        .merge(handlers::cards::card_ruling::card_ruling_router())
        .merge(handlers::cards::card_ability::card_ability_router())
        .merge(handlers::cards::deck::deck_router())
        .merge(handlers::cards::deck_card::deck_card_router())
        .merge(handlers::cards::deck_sideboard_card::deck_sideboard_card_router())
        .merge(handlers::cards::deck_tag::deck_tag_router())
        .merge(handlers::cards::deck_tag_assignment::deck_tag_assignment_router())
        .merge(handlers::players::player::player_router())
        .merge(handlers::players::player_season_stats::player_season_stats_router())
        .merge(handlers::players::player_collection::player_collection_router())
        .merge(handlers::players::friendship::friendship_router())
        .merge(handlers::players::achievement::achievement_router())
        .merge(handlers::players::player_achievement::player_achievement_router())
        .merge(handlers::players::crafting_recipe::crafting_recipe_router())
        .merge(handlers::players::crafting_ingredient::crafting_ingredient_router())
        .merge(handlers::tournaments::season::season_router())
        .merge(handlers::tournaments::tournament::tournament_router())
        .merge(handlers::tournaments::tournament_judge::tournament_judge_router())
        .merge(handlers::tournaments::tournament_registration::tournament_registration_router())
        .merge(handlers::tournaments::tournament_round::tournament_round_router())
        .merge(handlers::tournaments::r#match::match_router())
        .merge(handlers::tournaments::game::game_router())
        .merge(handlers::tournaments::tournament_prize::tournament_prize_router())
        .merge(handlers::tournaments::awarded_prize::awarded_prize_router())
        .merge(handlers::marketplace::product::product_router())
        .merge(handlers::marketplace::order::order_router())
        .merge(handlers::marketplace::order_item::order_item_router())
        .merge(handlers::marketplace::coupon::coupon_router())
        .merge(handlers::marketplace::trade_listing::trade_listing_router())
        .merge(handlers::marketplace::trade_bid::trade_bid_router())
        .merge(handlers::marketplace::trade_transaction::trade_transaction_router())
        .merge(handlers::marketplace::card_price_history::card_price_history_router())
        .merge(handlers::marketplace::trade_dispute::trade_dispute_router())
        .merge(handlers::content::draft_session::draft_session_router())
        .merge(handlers::content::draft_participant::draft_participant_router())
        .merge(handlers::content::draft_pick::draft_pick_router())
        .merge(handlers::content::article::article_router())
        .merge(handlers::content::article_tag::article_tag_router())
        .merge(handlers::content::article_tag_assignment::article_tag_assignment_router())
        .merge(handlers::content::article_comment::article_comment_router())
        .merge(handlers::content::stream::stream_router())
        .layer(CorsLayer::permissive())
        .with_state(pool);

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::info!("Listening on {}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
