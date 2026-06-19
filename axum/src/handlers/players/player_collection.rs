use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::player_collection::{PlayerCollection, PlayerCollectionCreateRequest, PlayerCollectionUpdateRequest};

type AppState = SqlitePool;

fn validate_player_collection(payload: &PlayerCollectionCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.quantity > 0) { errors.push("Collection quantity must be greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct PlayerCollectionListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_player_collection(
    State(pool): State<AppState>,
    Query(params): Query<PlayerCollectionListParams>,
) -> Result<Json<Vec<PlayerCollection>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_player_collection(
    State(pool): State<AppState>,
    Json(payload): Json<PlayerCollectionCreateRequest>,
) -> Result<(StatusCode, Json<PlayerCollection>), (StatusCode, String)> {
    let errors = validate_player_collection(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(PlayerCollection,
        "INSERT INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, datetime('now'), datetime('now')) RETURNING *",
        payload.quantity, payload.foil, payload.condition, payload.acquired_at, payload.acquired_via, payload.player_id, payload.card_id
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

pub async fn get_player_collection(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    headers: axum::http::HeaderMap,
) -> Result<Json<PlayerCollection>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()))?;
    let uid = headers.get("x-user-id").and_then(|v| v.to_str().ok()).and_then(|s| s.parse::<i64>().ok());
    if uid.map(|u| u != row.player_id).unwrap_or(true) {
        return Err((StatusCode::FORBIDDEN, "You do not own this resource.".to_string()));
    }
    Ok(Json(row))
}

pub async fn patch_player_collection(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    headers: axum::http::HeaderMap,
    Json(payload): Json<PlayerCollectionUpdateRequest>,
) -> Result<Json<PlayerCollection>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()))?;
    let uid = headers.get("x-user-id").and_then(|v| v.to_str().ok()).and_then(|s| s.parse::<i64>().ok());
    if uid.map(|u| u != row.player_id).unwrap_or(true) {
        return Err((StatusCode::FORBIDDEN, "You do not own this resource.".to_string()));
    }
    if let Some(v) = payload.quantity { row.quantity = v; }
    if let Some(v) = payload.foil { row.foil = v as i64; }
    if let Some(v) = payload.condition { row.condition = v; }
    if let Some(v) = payload.acquired_at { row.acquired_at = v; }
    if let Some(v) = payload.acquired_via { row.acquired_via = v; }
    if let Some(v) = payload.player_id { row.player_id = v; }
    if let Some(v) = payload.card_id { row.card_id = v; }
    sqlx::query_unchecked!(
        "UPDATE player_collections SET quantity = $1, foil = $2, condition = $3, acquired_at = $4, acquired_via = $5, player_id = $6, card_id = $7, updated_at = datetime('now') WHERE id = $8",
        row.quantity, row.foil, row.condition, row.acquired_at, row.acquired_via, row.player_id, row.card_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_player_collection(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    headers: axum::http::HeaderMap,
) -> Result<StatusCode, (StatusCode, String)> {
    let existing = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()))?;
    let uid = headers.get("x-user-id").and_then(|v| v.to_str().ok()).and_then(|s| s.parse::<i64>().ok());
    if uid.map(|u| u != existing.player_id).unwrap_or(true) {
        return Err((StatusCode::FORBIDDEN, "You do not own this resource.".to_string()));
    }
    let result = sqlx::query_unchecked!("DELETE FROM player_collections WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn add_player_collection(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()))?;
    // TODO: implement add business logic
    Ok(StatusCode::OK)
}

pub async fn remove_player_collection(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()))?;
    // TODO: implement remove business logic
    Ok(StatusCode::OK)
}

pub async fn estimated_value_player_collection(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerCollection, "SELECT * FROM player_collections WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerCollection not found".to_string()))?;
    // TODO: implement estimated_value business logic
    Ok(StatusCode::OK)
}

pub fn player_collection_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/player_collections", axum::routing::get(list_player_collection).post(create_player_collection))
        .route("/api/player_collections/:id", axum::routing::MethodRouter::new().get(get_player_collection).patch(patch_player_collection).delete(delete_player_collection))
        .route("/api/player_collections/:id/api/collection/{id}/add", axum::routing::post(add_player_collection))
        .route("/api/player_collections/:id/api/collection/{id}/remove", axum::routing::post(remove_player_collection))
        .route("/api/player_collections/:id/api/collection/{id}/value", axum::routing::get(estimated_value_player_collection))
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
        player_collection_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_player_collection() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/player_collections").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_player_collection() {
        let pool = setup_pool().await;
        let body = json!({
        "quantity": 2,
        "foil": false,
        "condition": "Mint",
        "acquired_at": "2024-01-01T00:00:00Z",
        "acquired_via": "Purchase",
        "player_id": 1,
        "card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/player_collections")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_player_collection() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().header("x-user-id", "1").uri("/api/player_collections/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_player_collection() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/player_collections/1").header("x-user-id", "1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
