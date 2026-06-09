use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::draft_pick::{DraftPick};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct DraftPickListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_draft_pick(
    State(pool): State<AppState>,
    Query(params): Query<DraftPickListParams>,
) -> Result<Json<Vec<DraftPick>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(DraftPick, "SELECT * FROM draft_picks LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn get_draft_pick(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftPick>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DraftPick, "SELECT * FROM draft_picks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftPick not found".to_string()))?;
    Ok(Json(row))
}

pub async fn is_first_pick_draft_pick(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftPick, "SELECT * FROM draft_picks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftPick not found".to_string()))?;
    // TODO: implement is_first_pick business logic
    Ok(StatusCode::OK)
}

pub fn draft_pick_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/draft_picks", axum::routing::get(list_draft_pick))
        .route("/api/draft_picks/:id", axum::routing::MethodRouter::new().get(get_draft_pick))
        .route("/api/draft_picks/:id/api/draft-picks/{id}/first-pick", axum::routing::get(is_first_pick_draft_pick))
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
        draft_pick_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_draft_pick() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/draft_picks").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_retrieve_draft_pick() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/draft_picks/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
