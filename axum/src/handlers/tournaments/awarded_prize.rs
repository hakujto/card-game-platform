use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::awarded_prize::{AwardedPrize};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct AwardedPrizeListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_awarded_prize(
    State(pool): State<AppState>,
    Query(params): Query<AwardedPrizeListParams>,
) -> Result<Json<Vec<AwardedPrize>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(AwardedPrize, "SELECT * FROM awarded_prizes LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn get_awarded_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<AwardedPrize>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(AwardedPrize, "SELECT * FROM awarded_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "AwardedPrize not found".to_string()))
        .map(Json)
}

pub async fn claim_awarded_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(AwardedPrize, "SELECT * FROM awarded_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "AwardedPrize not found".to_string()))?;
    // TODO: implement claim business logic
    Ok(StatusCode::OK)
}

pub async fn set_claimed_awarded_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<serde_json::Value>,
) -> Result<Json<AwardedPrize>, (StatusCode, String)> {
    let mut row = sqlx::query_as_unchecked!(AwardedPrize, "SELECT * FROM awarded_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "AwardedPrize not found".to_string()))?;
    let value = payload["value"].as_bool().unwrap_or(false);
    row.claimed = value as i64;
    if value == true {
        // @on(claimed = true): claim triggered
        // TODO: implement claim side-effect
    }
    sqlx::query_unchecked!(
        "UPDATE awarded_prizes SET claimed = $1, updated_at = datetime('now') WHERE id = $2",
        row.claimed, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub fn awarded_prize_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/awarded_prizes", axum::routing::get(list_awarded_prize))
        .route("/api/awarded_prizes/:id", axum::routing::MethodRouter::new().get(get_awarded_prize))
        .route("/api/awarded_prizes/:id/api/awarded-prizes/{id}/claim", axum::routing::post(claim_awarded_prize))
        .route("/api/awarded_prizes/:id/claimed", axum::routing::patch(set_claimed_awarded_prize))
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
        awarded_prize_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_awarded_prize() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/awarded_prizes").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_retrieve_awarded_prize() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/awarded_prizes/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
