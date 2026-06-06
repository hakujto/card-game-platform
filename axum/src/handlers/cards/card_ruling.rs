use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::card_ruling::{CardRuling, CardRulingCreateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct CardRulingListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_card_ruling(
    State(pool): State<AppState>,
    Query(params): Query<CardRulingListParams>,
) -> Result<Json<Vec<CardRuling>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(CardRuling, "SELECT * FROM card_rulings LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_card_ruling(
    State(pool): State<AppState>,
    Json(payload): Json<CardRulingCreateRequest>,
) -> Result<(StatusCode, Json<CardRuling>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(CardRuling,
        "INSERT INTO card_rulings (ruling_text, published_at, source, card_id, created_at, updated_at) VALUES ($1, $2, $3, $4, datetime('now'), datetime('now')) RETURNING *",
        payload.ruling_text, payload.published_at, payload.source, payload.card_id
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

pub async fn get_card_ruling(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<CardRuling>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(CardRuling, "SELECT * FROM card_rulings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardRuling not found".to_string()))
        .map(Json)
}

pub async fn delete_card_ruling(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM card_rulings WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "CardRuling not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn is_current_card_ruling(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardRuling, "SELECT * FROM card_rulings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardRuling not found".to_string()))?;
    // TODO: implement is_current business logic
    Ok(StatusCode::OK)
}

pub async fn supersedes_previous_card_ruling(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardRuling, "SELECT * FROM card_rulings WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardRuling not found".to_string()))?;
    // TODO: implement supersedes_previous business logic
    Ok(StatusCode::OK)
}

pub fn card_ruling_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/card_rulings", axum::routing::get(list_card_ruling).post(create_card_ruling))
        .route("/api/card_rulings/:id", axum::routing::MethodRouter::new().get(get_card_ruling).delete(delete_card_ruling))
        .route("/api/card_rulings/:id/api/card-rulings/{id}/current", axum::routing::get(is_current_card_ruling))
        .route("/api/card_rulings/:id/api/card-rulings/{id}/supersedes", axum::routing::get(supersedes_previous_card_ruling))
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
        card_ruling_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_card_ruling() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_rulings").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_card_ruling() {
        let pool = setup_pool().await;
        let body = json!({
        "ruling_text": "test",
        "published_at": "2024-01-01",
        "source": "test",
        "card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/card_rulings")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_card_ruling() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_rulings/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_card_ruling() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/card_rulings/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
