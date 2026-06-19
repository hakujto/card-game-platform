use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::card_set::{CardSet, CardSetCreateRequest, CardSetUpdateRequest};

type AppState = SqlitePool;

fn validate_card_set(payload: &CardSetCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.total_cards > 0) { errors.push("Card set must have at least one card".to_string()); }
    if !((!(payload.rotation_date.is_some()) || payload.rotation_date.as_deref() > Some(payload.release_date.as_str()))) { errors.push("Rotation date must be after release date".to_string()); }
    if !((!(payload.is_rotated == true) || payload.rotation_date.is_some())) { errors.push("Rotated set must have a rotation date".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct CardSetListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_card_set(
    State(pool): State<AppState>,
    Query(params): Query<CardSetListParams>,
) -> Result<Json<Vec<CardSet>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(CardSet,
            "SELECT * FROM card_sets WHERE (name LIKE '%' || $3 || '%' OR code LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_card_set(
    State(pool): State<AppState>,
    Json(payload): Json<CardSetCreateRequest>,
) -> Result<(StatusCode, Json<CardSet>), (StatusCode, String)> {
    let errors = validate_card_set(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(CardSet,
        "INSERT INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.code, payload.release_date, payload.rotation_date, payload.set_type, payload.total_cards, payload.is_rotated, payload.description, payload.logo_url
    ).fetch_one(&pool).await
    .map_err(|e| {
        // @unique fields: code
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<CardSet>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CardSetCreateRequest>,
) -> Result<Json<CardSet>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(CardSet,
        "UPDATE card_sets SET name = $1, code = $2, release_date = $3, rotation_date = $4, set_type = $5, total_cards = $6, is_rotated = $7, description = $8, logo_url = $9, updated_at = datetime('now') WHERE id = $10 RETURNING *",
        payload.name, payload.code, payload.release_date, payload.rotation_date, payload.set_type, payload.total_cards, payload.is_rotated, payload.description, payload.logo_url, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CardSetUpdateRequest>,
) -> Result<Json<CardSet>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.code { row.code = v; }
    if let Some(v) = payload.release_date { row.release_date = v; }
    if let Some(v) = payload.rotation_date { row.rotation_date = Some(v); }
    if let Some(v) = payload.set_type { row.set_type = v; }
    if let Some(v) = payload.total_cards { row.total_cards = v; }
    if let Some(v) = payload.is_rotated { row.is_rotated = v as i64; }
    if let Some(v) = payload.description { row.description = Some(v); }
    if let Some(v) = payload.logo_url { row.logo_url = Some(v); }
    sqlx::query_unchecked!(
        "UPDATE card_sets SET name = $1, code = $2, release_date = $3, rotation_date = $4, set_type = $5, total_cards = $6, is_rotated = $7, description = $8, logo_url = $9, updated_at = datetime('now') WHERE id = $10",
        row.name, row.code, row.release_date, row.rotation_date, row.set_type, row.total_cards, row.is_rotated, row.description, row.logo_url, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn is_legal_in_standard_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    // TODO: implement is_legal_in_standard business logic
    Ok(StatusCode::OK)
}

pub async fn is_legal_in_format_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    // TODO: implement is_legal_in_format business logic
    Ok(StatusCode::OK)
}

pub async fn card_count_by_rarity_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    // TODO: implement card_count_by_rarity business logic
    Ok(StatusCode::OK)
}

pub async fn rotate_out_card_set(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardSet, "SELECT * FROM card_sets WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardSet not found".to_string()))?;
    // TODO: implement rotate_out business logic
    Ok(StatusCode::OK)
}

pub fn card_set_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/card_sets", axum::routing::get(list_card_set).post(create_card_set))
        .route("/api/card_sets/:id", axum::routing::MethodRouter::new().get(get_card_set).put(update_card_set).patch(patch_card_set))
        .route("/api/card_sets/:id/api/card-sets/{id}/standard-legal", axum::routing::get(is_legal_in_standard_card_set))
        .route("/api/card_sets/:id/api/card-sets/{id}/legal", axum::routing::get(is_legal_in_format_card_set))
        .route("/api/card_sets/:id/api/card-sets/{id}/rarity-count", axum::routing::get(card_count_by_rarity_card_set))
        .route("/api/card_sets/:id/api/card-sets/{id}/rotate", axum::routing::post(rotate_out_card_set))
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
        card_set_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_card_set() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_sets").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_card_set() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_sets?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_card_set() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "code": "test",
        "release_date": "2024-01-01",
        "set_type": "Core",
        "total_cards": 2,
        "is_rotated": false
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/card_sets")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_card_set() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_sets/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_card_set() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "code": "test",
        "release_date": "2024-01-01",
        "set_type": "Core",
        "total_cards": 2,
        "is_rotated": false
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/card_sets")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/card_sets/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
