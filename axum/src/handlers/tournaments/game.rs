use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::game::{Game, GameCreateRequest, GameWinnerSide};

type AppState = SqlitePool;

fn validate_game(payload: &GameCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((payload.game_number >= 1 && payload.game_number <= 3)) { errors.push("Game number must be between 1 and 3 (best-of-3)".to_string()); }
    if !((!(payload.turns_played.is_some()) || payload.turns_played.map_or(false, |v| v > 0))) { errors.push("Turns played must be greater than zero".to_string()); }
    if !((!(payload.duration_seconds.is_some()) || payload.duration_seconds.map_or(false, |v| v > 0))) { errors.push("Game duration must be greater than zero".to_string()); }
    if !((!(payload.winner_side.as_ref() == Some(&GameWinnerSide::Draw)) || payload.winner_id.is_none())) { errors.push("A draw cannot have a winner".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct GameListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_game(
    State(pool): State<AppState>,
    Query(params): Query<GameListParams>,
) -> Result<Json<Vec<Game>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(Game, "SELECT * FROM games LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_game(
    State(pool): State<AppState>,
    Json(payload): Json<GameCreateRequest>,
) -> Result<(StatusCode, Json<Game>), (StatusCode, String)> {
    let errors = validate_game(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Game,
        "INSERT INTO games (game_number, winner_side, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, datetime('now'), datetime('now')) RETURNING *",
        payload.game_number, payload.winner_side, payload.turns_played, payload.duration_seconds, payload.ended_by, payload.replay_url, payload.match_id, payload.winner_id
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

pub async fn get_game(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Game>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Game, "SELECT * FROM games WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Game not found".to_string()))?;
    Ok(Json(row))
}

pub async fn record_winner_game(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Game, "SELECT * FROM games WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Game not found".to_string()))?;
    // TODO: implement record_winner business logic
    Ok(StatusCode::OK)
}

pub async fn duration_minutes_game(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Game, "SELECT * FROM games WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Game not found".to_string()))?;
    // TODO: implement duration_minutes business logic
    Ok(StatusCode::OK)
}

pub fn game_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/games", axum::routing::get(list_game).post(create_game))
        .route("/api/games/:id", axum::routing::MethodRouter::new().get(get_game))
        .route("/api/games/:id/winner", axum::routing::post(record_winner_game))
        .route("/api/games/:id/duration", axum::routing::get(duration_minutes_game))
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
        game_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_game() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/games").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_game() {
        let pool = setup_pool().await;
        let body = json!({
        "game_number": 2,
        "match_id": 1,
        "winner_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/games")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_game() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/games/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
