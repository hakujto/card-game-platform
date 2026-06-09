use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::deck_tag_assignment::{DeckTagAssignment, DeckTagAssignmentCreateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct DeckTagAssignmentListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_deck_tag_assignment(
    State(pool): State<AppState>,
    Query(params): Query<DeckTagAssignmentListParams>,
) -> Result<Json<Vec<DeckTagAssignment>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(DeckTagAssignment, "SELECT * FROM deck_tag_assignments LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_deck_tag_assignment(
    State(pool): State<AppState>,
    Json(payload): Json<DeckTagAssignmentCreateRequest>,
) -> Result<(StatusCode, Json<DeckTagAssignment>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DeckTagAssignment,
        "INSERT INTO deck_tag_assignments (deck_id, tag_id, created_at, updated_at) VALUES ($1, $2, datetime('now'), datetime('now')) RETURNING *",
        payload.deck_id, payload.tag_id
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

pub async fn get_deck_tag_assignment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DeckTagAssignment>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DeckTagAssignment, "SELECT * FROM deck_tag_assignments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckTagAssignment not found".to_string()))?;
    Ok(Json(row))
}

pub async fn delete_deck_tag_assignment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM deck_tag_assignments WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "DeckTagAssignment not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub fn deck_tag_assignment_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/deck_tag_assignments", axum::routing::get(list_deck_tag_assignment).post(create_deck_tag_assignment))
        .route("/api/deck_tag_assignments/:id", axum::routing::MethodRouter::new().get(get_deck_tag_assignment).delete(delete_deck_tag_assignment))
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
        deck_tag_assignment_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_deck_tag_assignment() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_tag_assignments").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_deck_tag_assignment() {
        let pool = setup_pool().await;
        let body = json!({
        "deck_id": 1,
        "tag_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/deck_tag_assignments")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_deck_tag_assignment() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_tag_assignments/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_deck_tag_assignment() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/deck_tag_assignments/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
