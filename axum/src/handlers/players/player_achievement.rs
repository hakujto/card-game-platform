use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::player_achievement::{PlayerAchievement};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct PlayerAchievementListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_player_achievement(
    State(pool): State<AppState>,
    Query(params): Query<PlayerAchievementListParams>,
) -> Result<Json<Vec<PlayerAchievement>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(PlayerAchievement, "SELECT * FROM player_achievements LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn get_player_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<PlayerAchievement>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(PlayerAchievement, "SELECT * FROM player_achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerAchievement not found".to_string()))?;
    Ok(Json(row))
}

pub async fn increment_progress_player_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerAchievement, "SELECT * FROM player_achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerAchievement not found".to_string()))?;
    // TODO: implement increment_progress business logic
    Ok(StatusCode::OK)
}

pub async fn complete_player_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerAchievement, "SELECT * FROM player_achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerAchievement not found".to_string()))?;
    // TODO: implement complete business logic
    Ok(StatusCode::OK)
}

pub async fn set_is_completed_player_achievement(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<serde_json::Value>,
) -> Result<Json<PlayerAchievement>, (StatusCode, String)> {
    let mut row = sqlx::query_as_unchecked!(PlayerAchievement, "SELECT * FROM player_achievements WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerAchievement not found".to_string()))?;
    let value = payload["value"].as_bool().unwrap_or(false);
    row.is_completed = value as i64;
    if value == true {
        // @on(is_completed = true): complete triggered
        // TODO: implement complete side-effect
    }
    sqlx::query_unchecked!(
        "UPDATE player_achievements SET is_completed = $1, updated_at = datetime('now') WHERE id = $2",
        row.is_completed, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub fn player_achievement_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/player_achievements", axum::routing::get(list_player_achievement))
        .route("/api/player_achievements/:id", axum::routing::MethodRouter::new().get(get_player_achievement))
        .route("/api/player_achievements/:id/progress", axum::routing::patch(increment_progress_player_achievement))
        .route("/api/player_achievements/:id/complete", axum::routing::post(complete_player_achievement))
        .route("/api/player_achievements/:id/is_completed", axum::routing::patch(set_is_completed_player_achievement))
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
        sqlx::query("PRAGMA foreign_keys = OFF").execute(&pool).await.unwrap();
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        player_achievement_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_player_achievement() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/player_achievements").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_retrieve_player_achievement() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/player_achievements/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
