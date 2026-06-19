use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::player_season_stats::{PlayerSeasonStats};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct PlayerSeasonStatsListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_player_season_stats(
    State(pool): State<AppState>,
    Query(params): Query<PlayerSeasonStatsListParams>,
) -> Result<Json<Vec<PlayerSeasonStats>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(PlayerSeasonStats, "SELECT * FROM player_season_statses LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn get_player_season_stats(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<PlayerSeasonStats>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(PlayerSeasonStats, "SELECT * FROM player_season_statses WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerSeasonStats not found".to_string()))?;
    Ok(Json(row))
}

pub async fn win_rate_player_season_stats(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerSeasonStats, "SELECT * FROM player_season_statses WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerSeasonStats not found".to_string()))?;
    // TODO: implement win_rate business logic
    Ok(StatusCode::OK)
}

pub async fn add_points_player_season_stats(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerSeasonStats, "SELECT * FROM player_season_statses WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerSeasonStats not found".to_string()))?;
    // TODO: implement add_points business logic
    Ok(StatusCode::OK)
}

pub async fn record_tournament_win_player_season_stats(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(PlayerSeasonStats, "SELECT * FROM player_season_statses WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "PlayerSeasonStats not found".to_string()))?;
    // TODO: implement record_tournament_win business logic
    Ok(StatusCode::OK)
}

pub fn player_season_stats_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/player_season_statses", axum::routing::get(list_player_season_stats))
        .route("/api/player_season_statses/:id", axum::routing::MethodRouter::new().get(get_player_season_stats))
        .route("/api/player_season_statses/:id/api/player-season-stats/{id}/win-rate", axum::routing::get(win_rate_player_season_stats))
        .route("/api/player_season_statses/:id/api/player-season-stats/{id}/points", axum::routing::patch(add_points_player_season_stats))
        .route("/api/player_season_statses/:id/api/player-season-stats/{id}/tournament-win", axum::routing::post(record_tournament_win_player_season_stats))
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
        player_season_stats_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_player_season_stats() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/player_season_statses").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_retrieve_player_season_stats() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/player_season_statses/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
