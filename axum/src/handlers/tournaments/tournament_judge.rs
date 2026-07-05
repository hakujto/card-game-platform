use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::tournament_judge::{TournamentJudge, TournamentJudgeCreateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct TournamentJudgeListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_tournament_judge(
    State(pool): State<AppState>,
    Query(params): Query<TournamentJudgeListParams>,
) -> Result<Json<Vec<TournamentJudge>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TournamentJudge, "SELECT * FROM tournament_judges LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_tournament_judge(
    State(pool): State<AppState>,
    Json(payload): Json<TournamentJudgeCreateRequest>,
) -> Result<(StatusCode, Json<TournamentJudge>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TournamentJudge,
        "INSERT INTO tournament_judges (role, tournament_id, player_id, created_at, updated_at) VALUES ($1, $2, $3, datetime('now'), datetime('now')) RETURNING *",
        payload.role, payload.tournament_id, payload.player_id
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

pub async fn get_tournament_judge(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TournamentJudge>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TournamentJudge, "SELECT * FROM tournament_judges WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentJudge not found".to_string()))?;
    Ok(Json(row))
}

pub async fn delete_tournament_judge(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM tournament_judges WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "TournamentJudge not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn promote_to_head_tournament_judge(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentJudge, "SELECT * FROM tournament_judges WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentJudge not found".to_string()))?;
    // TODO: implement promote_to_head business logic
    Ok(StatusCode::OK)
}

pub async fn remove_tournament_judge(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentJudge, "SELECT * FROM tournament_judges WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentJudge not found".to_string()))?;
    // TODO: implement remove business logic
    Ok(StatusCode::OK)
}

pub fn tournament_judge_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/tournament_judges", axum::routing::get(list_tournament_judge).post(create_tournament_judge))
        .route("/api/tournament_judges/:id", axum::routing::MethodRouter::new().get(get_tournament_judge).delete(delete_tournament_judge))
        .route("/api/tournament_judges/:id/promote", axum::routing::post(promote_to_head_tournament_judge))
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
        tournament_judge_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_tournament_judge() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_judges").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_tournament_judge() {
        let pool = setup_pool().await;
        let body = json!({
        "role": "HeadJudge",
        "tournament_id": 1,
        "player_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/tournament_judges")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_tournament_judge() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_judges/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_tournament_judge() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/tournament_judges/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
