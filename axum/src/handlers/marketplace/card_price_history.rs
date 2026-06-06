use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::card_price_history::{CardPriceHistory};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct CardPriceHistoryListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_card_price_history(
    State(pool): State<AppState>,
    Query(params): Query<CardPriceHistoryListParams>,
) -> Result<Json<Vec<CardPriceHistory>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(CardPriceHistory, "SELECT * FROM card_price_histories LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn get_card_price_history(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<CardPriceHistory>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(CardPriceHistory, "SELECT * FROM card_price_histories WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardPriceHistory not found".to_string()))
        .map(Json)
}

pub async fn price_change_percent_card_price_history(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardPriceHistory, "SELECT * FROM card_price_histories WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardPriceHistory not found".to_string()))?;
    // TODO: implement price_change_percent business logic
    Ok(StatusCode::OK)
}

pub async fn is_price_spike_card_price_history(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardPriceHistory, "SELECT * FROM card_price_histories WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardPriceHistory not found".to_string()))?;
    // TODO: implement is_price_spike business logic
    Ok(StatusCode::OK)
}

pub fn card_price_history_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/card_price_histories", axum::routing::get(list_card_price_history))
        .route("/api/card_price_histories/:id", axum::routing::MethodRouter::new().get(get_card_price_history))
        .route("/api/card_price_histories/:id/api/price-history/{id}/change", axum::routing::get(price_change_percent_card_price_history))
        .route("/api/card_price_histories/:id/api/price-history/{id}/spike", axum::routing::get(is_price_spike_card_price_history))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::{Request, StatusCode};
    use tower::ServiceExt;
    use sqlx::SqlitePool;

    async fn setup_pool() -> SqlitePool {
        let pool = SqlitePool::connect(":memory:").await.unwrap();
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        card_price_history_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_card_price_history() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_price_histories").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_retrieve_card_price_history() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_price_histories/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
