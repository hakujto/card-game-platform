use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::trade_listing::{TradeListing, TradeListingCreateRequest, TradeListingUpdateRequest, TradeListingListingType};

type AppState = SqlitePool;

fn validate_trade_listing(payload: &TradeListingCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.listing_type == TradeListingListingType::FixedPrice) || payload.asking_price.is_some())) { errors.push("Fixed price listing must have an asking price".to_string()); }
    if !((!(payload.listing_type == TradeListingListingType::Auction) || (payload.auction_start_price.is_some() && payload.auction_end_time.is_some()))) { errors.push("Auction listing must have a start price and end time".to_string()); }
    if !((payload.quantity >= 1 && payload.quantity <= 9999)) { errors.push("Listing quantity must be between 1 and 9999".to_string()); }
    // @required_when: asking_price — {"type":"eq","field":"listing_type","value":"FixedPrice"}
    errors
}

#[derive(Deserialize)]
pub struct TradeListingListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_trade_listing(
    State(pool): State<AppState>,
    Query(params): Query<TradeListingListParams>,
) -> Result<Json<Vec<TradeListing>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(TradeListing,
            "SELECT * FROM trade_listings WHERE (description LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_trade_listing(
    State(pool): State<AppState>,
    Json(payload): Json<TradeListingCreateRequest>,
) -> Result<(StatusCode, Json<TradeListing>), (StatusCode, String)> {
    let errors = validate_trade_listing(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(TradeListing,
        "INSERT INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, datetime('now'), datetime('now')) RETURNING *",
        payload.public_id, payload.status, payload.listing_type, payload.asking_price, payload.auction_start_price, payload.auction_current_bid, payload.auction_end_time, payload.foil, payload.condition, payload.quantity, payload.description, payload.expires_at, payload.seller_id, payload.card_id
    ).fetch_one(&pool).await
    .map_err(|e| {
        // @unique fields: public_id
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<TradeListingUpdateRequest>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    if let Some(v) = payload.public_id { row.public_id = v; }
    if let Some(v) = payload.listing_type { row.listing_type = v; }
    if let Some(v) = payload.asking_price { row.asking_price = Some(v); }
    if let Some(v) = payload.auction_start_price { row.auction_start_price = Some(v); }
    if let Some(v) = payload.auction_current_bid { row.auction_current_bid = Some(v); }
    if let Some(v) = payload.auction_end_time { row.auction_end_time = Some(v); }
    if let Some(v) = payload.foil { row.foil = v as i64; }
    if let Some(v) = payload.condition { row.condition = v; }
    if let Some(v) = payload.quantity { row.quantity = v; }
    if let Some(v) = payload.description { row.description = Some(v); }
    if let Some(v) = payload.expires_at { row.expires_at = Some(v); }
    if let Some(v) = payload.seller_id { row.seller_id = v; }
    if let Some(v) = payload.card_id { row.card_id = v; }
    sqlx::query_unchecked!(
        "UPDATE trade_listings SET public_id = $1, listing_type = $2, asking_price = $3, auction_start_price = $4, auction_current_bid = $5, auction_end_time = $6, foil = $7, condition = $8, quantity = $9, description = $10, expires_at = $11, seller_id = $12, card_id = $13, updated_at = datetime('now') WHERE id = $14",
        row.public_id, row.listing_type, row.asking_price, row.auction_start_price, row.auction_current_bid, row.auction_end_time, row.foil, row.condition, row.quantity, row.description, row.expires_at, row.seller_id, row.card_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn close_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    // TODO: implement close business logic
    Ok(StatusCode::OK)
}

pub async fn extend_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    // TODO: implement extend business logic
    Ok(StatusCode::OK)
}

pub async fn cancel_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    // @guard: TODO: evaluate guard condition — return 422 if not met
    // if !(guard_condition) { return Err((StatusCode::UNPROCESSABLE_ENTITY, "Guard condition not met for cancel".to_string())); }
    // TODO: implement cancel business logic
    Ok(StatusCode::OK)
}

pub async fn is_expired_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    // TODO: implement is_expired business logic
    Ok(StatusCode::OK)
}

pub async fn finalize_auction_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    // RBAC: allowed roles: admin, seller
    // TODO: extract role from request and check against allowed roles
    let _row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    // TODO: implement finalize_auction business logic
    Ok(StatusCode::OK)
}

pub async fn set_status_trade_listing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<serde_json::Value>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    let mut row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    let value = payload["value"].as_str().unwrap_or("").to_string();
    row.status = value.clone().into();
    if value.as_str() == "Sold" {
        // @on(status = Sold): finalize_auction triggered
        // TODO: implement finalize_auction side-effect
    }
    sqlx::query_unchecked!(
        "UPDATE trade_listings SET status = $1, updated_at = datetime('now') WHERE id = $2",
        row.status, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn transition_trade_listing_pending_to_active(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    row.assert_transition("Active").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeListing,
        "UPDATE trade_listings SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Active", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_trade_listing_active_to_sold(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    row.assert_transition("Sold").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeListing,
        "UPDATE trade_listings SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Sold", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_trade_listing_active_to_expired(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    row.assert_transition("Expired").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeListing,
        "UPDATE trade_listings SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Expired", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_trade_listing_active_to_cancelled(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeListing>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(TradeListing, "SELECT * FROM trade_listings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeListing not found".to_string()))?;
    row.assert_transition("Cancelled").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeListing,
        "UPDATE trade_listings SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Cancelled", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub fn trade_listing_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/trade_listings", axum::routing::get(list_trade_listing).post(create_trade_listing))
        .route("/api/trade_listings/:id", axum::routing::MethodRouter::new().get(get_trade_listing).patch(patch_trade_listing))
        .route("/api/trade_listings/:id/close", axum::routing::post(close_trade_listing))
        .route("/api/trade_listings/:id/extend", axum::routing::patch(extend_trade_listing))
        .route("/api/trade_listings/:id/cancel", axum::routing::delete(cancel_trade_listing))
        .route("/api/trade_listings/:id/expired", axum::routing::get(is_expired_trade_listing))
        .route("/api/trade_listings/:id/finalize", axum::routing::post(finalize_auction_trade_listing))
        .route("/api/trade_listings/:id/status", axum::routing::patch(set_status_trade_listing))
        .route("/api/trade_listings/:id/transitions/pending-to-active", axum::routing::patch(transition_trade_listing_pending_to_active))
        .route("/api/trade_listings/:id/transitions/active-to-sold", axum::routing::patch(transition_trade_listing_active_to_sold))
        .route("/api/trade_listings/:id/transitions/active-to-expired", axum::routing::patch(transition_trade_listing_active_to_expired))
        .route("/api/trade_listings/:id/transitions/active-to-cancelled", axum::routing::patch(transition_trade_listing_active_to_cancelled))
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
        sqlx::query("PRAGMA foreign_keys = OFF").execute(&pool).await.unwrap();
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        trade_listing_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_trade_listing() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_listings").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_trade_listing() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_listings?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_trade_listing() {
        let pool = setup_pool().await;
        let body = json!({
        "public_id": "00000000-0000-0000-0000-000000000001",
        "status": "Active",
        "listing_type": "TradeOffer",
        "foil": false,
        "condition": "Mint",
        "quantity": 2,
        "seller_id": 1,
        "card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/trade_listings")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_trade_listing() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_listings/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_trade_listing() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "public_id": "00000000-0000-0000-0000-000000000001",
        "status": "Active",
        "listing_type": "TradeOffer",
        "foil": false,
        "condition": "Mint",
        "quantity": 2,
        "seller_id": 1,
        "card_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/trade_listings")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "description": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/trade_listings/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
