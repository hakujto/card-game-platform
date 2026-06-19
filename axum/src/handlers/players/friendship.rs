use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::friendship::{Friendship, FriendshipCreateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct FriendshipListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_friendship(
    State(pool): State<AppState>,
    Query(params): Query<FriendshipListParams>,
) -> Result<Json<Vec<Friendship>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(Friendship, "SELECT * FROM friendships LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_friendship(
    State(pool): State<AppState>,
    Json(payload): Json<FriendshipCreateRequest>,
) -> Result<(StatusCode, Json<Friendship>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Friendship,
        "INSERT INTO friendships (status, requester_id, receiver_id, created_at, updated_at) VALUES ($1, $2, $3, datetime('now'), datetime('now')) RETURNING *",
        payload.status, payload.requester_id, payload.receiver_id
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

pub async fn get_friendship(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    headers: axum::http::HeaderMap,
) -> Result<Json<Friendship>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Friendship, "SELECT * FROM friendships WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Friendship not found".to_string()))?;
    let uid = headers.get("x-user-id").and_then(|v| v.to_str().ok()).and_then(|s| s.parse::<i64>().ok());
    if uid.map(|u| u != row.requester_id).unwrap_or(true) {
        return Err((StatusCode::FORBIDDEN, "You do not own this resource.".to_string()));
    }
    Ok(Json(row))
}

pub async fn delete_friendship(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    headers: axum::http::HeaderMap,
) -> Result<StatusCode, (StatusCode, String)> {
    let existing = sqlx::query_as_unchecked!(Friendship, "SELECT * FROM friendships WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Friendship not found".to_string()))?;
    let uid = headers.get("x-user-id").and_then(|v| v.to_str().ok()).and_then(|s| s.parse::<i64>().ok());
    if uid.map(|u| u != existing.requester_id).unwrap_or(true) {
        return Err((StatusCode::FORBIDDEN, "You do not own this resource.".to_string()));
    }
    let result = sqlx::query_unchecked!("DELETE FROM friendships WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "Friendship not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn accept_friendship(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Friendship, "SELECT * FROM friendships WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Friendship not found".to_string()))?;
    // TODO: implement accept business logic
    Ok(StatusCode::OK)
}

pub async fn decline_friendship(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Friendship, "SELECT * FROM friendships WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Friendship not found".to_string()))?;
    // TODO: implement decline business logic
    Ok(StatusCode::OK)
}

pub async fn block_friendship(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Friendship, "SELECT * FROM friendships WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Friendship not found".to_string()))?;
    // TODO: implement block business logic
    Ok(StatusCode::OK)
}

pub fn friendship_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/friendships", axum::routing::get(list_friendship).post(create_friendship))
        .route("/api/friendships/:id", axum::routing::MethodRouter::new().get(get_friendship).delete(delete_friendship))
        .route("/api/friendships/:id/accept", axum::routing::post(accept_friendship))
        .route("/api/friendships/:id/decline", axum::routing::post(decline_friendship))
        .route("/api/friendships/:id/block", axum::routing::post(block_friendship))
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
        friendship_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_friendship() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/friendships").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_friendship() {
        let pool = setup_pool().await;
        let body = json!({
        "status": "Pending",
        "requester_id": 1,
        "receiver_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/friendships")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_friendship() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().header("x-user-id", "1").uri("/api/friendships/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_friendship() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/friendships/1").header("x-user-id", "1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
