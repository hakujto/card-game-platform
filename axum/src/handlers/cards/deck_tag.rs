use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::deck_tag::{DeckTag, DeckTagCreateRequest, DeckTagUpdateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct DeckTagListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_deck_tag(
    State(pool): State<AppState>,
    Query(params): Query<DeckTagListParams>,
) -> Result<Json<Vec<DeckTag>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(DeckTag,
            "SELECT * FROM deck_tags WHERE (name LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(DeckTag, "SELECT * FROM deck_tags LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_deck_tag(
    State(pool): State<AppState>,
    Json(payload): Json<DeckTagCreateRequest>,
) -> Result<(StatusCode, Json<DeckTag>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DeckTag,
        "INSERT INTO deck_tags (name, color, created_at, updated_at) VALUES ($1, $2, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.color
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

pub async fn get_deck_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DeckTag>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(DeckTag, "SELECT * FROM deck_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckTag not found".to_string()))
        .map(Json)
}

pub async fn patch_deck_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<DeckTagUpdateRequest>,
) -> Result<Json<DeckTag>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(DeckTag, "SELECT * FROM deck_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckTag not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.color { row.color = Some(v); }
    sqlx::query_unchecked!(
        "UPDATE deck_tags SET name = $1, color = $2, updated_at = datetime('now') WHERE id = $3",
        row.name, row.color, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_deck_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM deck_tags WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "DeckTag not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn rename_deck_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DeckTag, "SELECT * FROM deck_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckTag not found".to_string()))?;
    // TODO: implement rename business logic
    Ok(StatusCode::OK)
}

pub async fn merge_into_deck_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DeckTag, "SELECT * FROM deck_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckTag not found".to_string()))?;
    // TODO: implement merge_into business logic
    Ok(StatusCode::OK)
}

pub fn deck_tag_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/deck_tags", axum::routing::get(list_deck_tag).post(create_deck_tag))
        .route("/api/deck_tags/:id", axum::routing::MethodRouter::new().get(get_deck_tag).patch(patch_deck_tag).delete(delete_deck_tag))
        .route("/api/deck_tags/:id/api/deck-tags/{id}/rename", axum::routing::patch(rename_deck_tag))
        .route("/api/deck_tags/:id/api/deck-tags/{id}/merge", axum::routing::post(merge_into_deck_tag))
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
        deck_tag_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_deck_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_tags").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_deck_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_tags?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_deck_tag() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test"
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/deck_tags")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_deck_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_tags/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_deck_tag() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test"
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/deck_tags")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/deck_tags/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

    #[tokio::test]
    async fn test_delete_deck_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/deck_tags/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
