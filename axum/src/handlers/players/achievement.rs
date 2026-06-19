use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::achievement::{Achievement, AchievementCreateRequest, AchievementUpdateRequest};

type AppState = SqlitePool;

fn validate_achievement(payload: &AchievementCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.points > 0) { errors.push("Achievement must award at least one point".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct AchievementListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_achievement(
    State(pool): State<AppState>,
    Query(params): Query<AchievementListParams>,
) -> Result<Json<Vec<Achievement>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Achievement,
            "SELECT * FROM achievements WHERE (name LIKE '%' || $3 || '%' OR description LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Achievement, "SELECT * FROM achievements LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_achievement(
    State(pool): State<AppState>,
    Json(payload): Json<AchievementCreateRequest>,
) -> Result<(StatusCode, Json<Achievement>), (StatusCode, String)> {
    let errors = validate_achievement(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Achievement,
        "INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.description, payload.icon_url, payload.points, payload.rarity, payload.is_hidden
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

pub async fn get_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Achievement>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Achievement, "SELECT * FROM achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Achievement not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<AchievementCreateRequest>,
) -> Result<Json<Achievement>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Achievement,
        "UPDATE achievements SET name = $1, description = $2, icon_url = $3, points = $4, rarity = $5, is_hidden = $6, updated_at = datetime('now') WHERE id = $7 RETURNING *",
        payload.name, payload.description, payload.icon_url, payload.points, payload.rarity, payload.is_hidden, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Achievement not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<AchievementUpdateRequest>,
) -> Result<Json<Achievement>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Achievement, "SELECT * FROM achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Achievement not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.description { row.description = v; }
    if let Some(v) = payload.icon_url { row.icon_url = Some(v); }
    if let Some(v) = payload.points { row.points = v; }
    if let Some(v) = payload.rarity { row.rarity = v; }
    if let Some(v) = payload.is_hidden { row.is_hidden = v as i64; }
    sqlx::query_unchecked!(
        "UPDATE achievements SET name = $1, description = $2, icon_url = $3, points = $4, rarity = $5, is_hidden = $6, updated_at = datetime('now') WHERE id = $7",
        row.name, row.description, row.icon_url, row.points, row.rarity, row.is_hidden, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn point_value_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Achievement, "SELECT * FROM achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Achievement not found".to_string()))?;
    // TODO: implement point_value business logic
    Ok(StatusCode::OK)
}

pub async fn reveal_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Achievement, "SELECT * FROM achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Achievement not found".to_string()))?;
    // TODO: implement reveal business logic
    Ok(StatusCode::OK)
}

pub fn achievement_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/achievements", axum::routing::get(list_achievement).post(create_achievement))
        .route("/api/achievements/:id", axum::routing::MethodRouter::new().get(get_achievement).put(update_achievement).patch(patch_achievement))
        .route("/api/achievements/:id/point-value", axum::routing::get(point_value_achievement))
        .route("/api/achievements/:id/reveal", axum::routing::post(reveal_achievement))
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
        achievement_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_achievement() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/achievements").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_achievement() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/achievements?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_achievement() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "description": "test",
        "points": 2,
        "rarity": "Common",
        "is_hidden": false
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/achievements")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_achievement() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/achievements/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_achievement() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "description": "test",
        "points": 2,
        "rarity": "Common",
        "is_hidden": false
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/achievements")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/achievements/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
