use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::trade_bid::{TradeBid, TradeBidCreateRequest};

type AppState = SqlitePool;

fn validate_trade_bid(payload: &TradeBidCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.amount > 0.0) { errors.push("Bid amount must be greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct TradeBidListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_trade_bid(
    State(pool): State<AppState>,
    Query(params): Query<TradeBidListParams>,
) -> Result<Json<Vec<TradeBid>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TradeBid, "SELECT * FROM trade_bids LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_trade_bid(
    State(pool): State<AppState>,
    Json(payload): Json<TradeBidCreateRequest>,
) -> Result<(StatusCode, Json<TradeBid>), (StatusCode, String)> {
    let errors = validate_trade_bid(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(TradeBid,
        "INSERT INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, datetime('now'), datetime('now')) RETURNING *",
        payload.amount, payload.placed_at, payload.is_winning, payload.listing_id, payload.bidder_id
    ).fetch_one(&pool).await
    .map_err(|e| {
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_trade_bid(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeBid>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TradeBid, "SELECT * FROM trade_bids WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeBid not found".to_string()))?;
    Ok(Json(row))
}

pub async fn outbid_by_trade_bid(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeBid, "SELECT * FROM trade_bids WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeBid not found".to_string()))?;
    // TODO: implement outbid_by business logic
    Ok(StatusCode::OK)
}

pub async fn retract_trade_bid(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeBid, "SELECT * FROM trade_bids WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeBid not found".to_string()))?;
    // TODO: implement retract business logic
    Ok(StatusCode::OK)
}

pub fn trade_bid_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/trade_bids", axum::routing::get(list_trade_bid).post(create_trade_bid))
        .route("/api/trade_bids/:id", axum::routing::MethodRouter::new().get(get_trade_bid))
        .route("/api/trade_bids/:id/api/bids/{id}/outbid", axum::routing::get(outbid_by_trade_bid))
        .route("/api/trade_bids/:id/api/bids/{id}", axum::routing::delete(retract_trade_bid))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::{Request, StatusCode};
    use serde_json::json;
    use tower::ServiceExt;
    use sqlx::SqlitePool;

    async fn setup_pool() -> SqlitePool {
        let pool = SqlitePool::connect(":memory:").await.unwrap();
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        trade_bid_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_trade_bid() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_bids").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_trade_bid() {
        let pool = setup_pool().await;
        let body = json!({
        "amount": 1.0,
        "placed_at": "2024-01-01T00:00:00Z",
        "is_winning": false,
        "listing_id": 1,
        "bidder_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/trade_bids")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_trade_bid() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_bids/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
