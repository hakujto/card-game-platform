use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::trade_dispute::{TradeDispute, TradeDisputeCreateRequest, TradeDisputeStatus};

type AppState = SqlitePool;

fn validate_trade_dispute(payload: &TradeDisputeCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.resolved_at.is_some()) || payload.status == TradeDisputeStatus::Resolved)) { errors.push("Validation failed: resolved_at_requires_terminal_status".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct TradeDisputeListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_trade_dispute(
    State(pool): State<AppState>,
    Query(params): Query<TradeDisputeListParams>,
) -> Result<Json<Vec<TradeDispute>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_trade_dispute(
    State(pool): State<AppState>,
    Json(payload): Json<TradeDisputeCreateRequest>,
) -> Result<(StatusCode, Json<TradeDispute>), (StatusCode, String)> {
    let errors = validate_trade_dispute(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(TradeDispute,
        "INSERT INTO trade_disputes (status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, datetime('now'), datetime('now')) RETURNING *",
        payload.status, payload.reason, payload.description, payload.resolution, payload.opened_at, payload.resolved_at, payload.transaction_id, payload.opened_by_id, payload.resolved_by_id
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

pub async fn get_trade_dispute(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeDispute>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    Ok(Json(row))
}

pub async fn escalate_trade_dispute(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    // TODO: implement escalate business logic
    Ok(StatusCode::OK)
}

pub async fn resolve_trade_dispute(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    // TODO: implement resolve business logic
    Ok(StatusCode::OK)
}

pub async fn close_resolved_trade_dispute(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    // TODO: implement close_resolved business logic
    Ok(StatusCode::OK)
}

pub async fn review_trade_dispute(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    // TODO: implement review business logic
    Ok(StatusCode::OK)
}

pub async fn transition_trade_dispute_open_to_underreview(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeDispute>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    row.assert_transition("UnderReview").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeDispute,
        "UPDATE trade_disputes SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "UnderReview", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_trade_dispute_underreview_to_resolved(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeDispute>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    row.assert_transition("Resolved").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeDispute,
        "UPDATE trade_disputes SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Resolved", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_trade_dispute_underreview_to_escalated(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeDispute>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    row.assert_transition("Escalated").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeDispute,
        "UPDATE trade_disputes SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Escalated", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_trade_dispute_escalated_to_resolved(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeDispute>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(TradeDispute, "SELECT * FROM trade_disputes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeDispute not found".to_string()))?;
    row.assert_transition("Resolved").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(TradeDispute,
        "UPDATE trade_disputes SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Resolved", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub fn trade_dispute_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/trade_disputes", axum::routing::get(list_trade_dispute).post(create_trade_dispute))
        .route("/api/trade_disputes/:id", axum::routing::MethodRouter::new().get(get_trade_dispute))
        .route("/api/trade_disputes/:id/api/disputes/{id}/escalate", axum::routing::post(escalate_trade_dispute))
        .route("/api/trade_disputes/:id/api/disputes/{id}/resolve", axum::routing::post(resolve_trade_dispute))
        .route("/api/trade_disputes/:id/api/disputes/{id}/close", axum::routing::post(close_resolved_trade_dispute))
        .route("/api/trade_disputes/:id/api/disputes/{id}/review", axum::routing::post(review_trade_dispute))
        .route("/api/trade_disputes/:id/transitions/open-to-underreview", axum::routing::patch(transition_trade_dispute_open_to_underreview))
        .route("/api/trade_disputes/:id/transitions/underreview-to-resolved", axum::routing::patch(transition_trade_dispute_underreview_to_resolved))
        .route("/api/trade_disputes/:id/transitions/underreview-to-escalated", axum::routing::patch(transition_trade_dispute_underreview_to_escalated))
        .route("/api/trade_disputes/:id/transitions/escalated-to-resolved", axum::routing::patch(transition_trade_dispute_escalated_to_resolved))
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
        trade_dispute_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_trade_dispute() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_disputes").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_trade_dispute() {
        let pool = setup_pool().await;
        let body = json!({
        "status": "Open",
        "reason": "ItemNotReceived",
        "description": "test",
        "opened_at": "2024-01-01T00:00:00Z",
        "transaction_id": 1,
        "opened_by_id": 1,
        "resolved_by_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/trade_disputes")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_trade_dispute() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_disputes/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
