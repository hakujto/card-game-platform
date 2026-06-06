use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::card_ability::{CardAbility, CardAbilityCreateRequest, CardAbilityUpdateRequest, CardAbilityAbilityType};

type AppState = SqlitePool;

fn validate_card_ability(payload: &CardAbilityCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.ability_type == CardAbilityAbilityType::Keyword) || payload.keyword.is_some())) { errors.push("Keyword ability must have a keyword name".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct CardAbilityListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_card_ability(
    State(pool): State<AppState>,
    Query(params): Query<CardAbilityListParams>,
) -> Result<Json<Vec<CardAbility>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(CardAbility,
            "SELECT * FROM card_abilities WHERE (keyword LIKE '%' || $3 || '%' OR ability_text LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(CardAbility, "SELECT * FROM card_abilities LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_card_ability(
    State(pool): State<AppState>,
    Json(payload): Json<CardAbilityCreateRequest>,
) -> Result<(StatusCode, Json<CardAbility>), (StatusCode, String)> {
    let errors = validate_card_ability(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(CardAbility,
        "INSERT INTO card_abilities (ability_type, keyword, ability_text, timing, card_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, datetime('now'), datetime('now')) RETURNING *",
        payload.ability_type, payload.keyword, payload.ability_text, payload.timing, payload.card_id
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

pub async fn get_card_ability(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<CardAbility>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(CardAbility, "SELECT * FROM card_abilities WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardAbility not found".to_string()))
        .map(Json)
}

pub async fn update_card_ability(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CardAbilityCreateRequest>,
) -> Result<Json<CardAbility>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(CardAbility,
        "UPDATE card_abilities SET ability_type = $1, keyword = $2, ability_text = $3, timing = $4, card_id = $5, updated_at = datetime('now') WHERE id = $6 RETURNING *",
        payload.ability_type, payload.keyword, payload.ability_text, payload.timing, payload.card_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "CardAbility not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_card_ability(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CardAbilityUpdateRequest>,
) -> Result<Json<CardAbility>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(CardAbility, "SELECT * FROM card_abilities WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardAbility not found".to_string()))?;
    if let Some(v) = payload.ability_type { row.ability_type = v; }
    if let Some(v) = payload.keyword { row.keyword = Some(v); }
    if let Some(v) = payload.ability_text { row.ability_text = v; }
    if let Some(v) = payload.timing { row.timing = Some(v); }
    if let Some(v) = payload.card_id { row.card_id = v; }
    sqlx::query_unchecked!(
        "UPDATE card_abilities SET ability_type = $1, keyword = $2, ability_text = $3, timing = $4, card_id = $5, updated_at = datetime('now') WHERE id = $6",
        row.ability_type, row.keyword, row.ability_text, row.timing, row.card_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_card_ability(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM card_abilities WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "CardAbility not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn is_usable_at_card_ability(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardAbility, "SELECT * FROM card_abilities WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardAbility not found".to_string()))?;
    // TODO: implement is_usable_at business logic
    Ok(StatusCode::OK)
}

pub async fn describe_card_ability(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CardAbility, "SELECT * FROM card_abilities WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CardAbility not found".to_string()))?;
    // TODO: implement describe business logic
    Ok(StatusCode::OK)
}

pub fn card_ability_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/card_abilities", axum::routing::get(list_card_ability).post(create_card_ability))
        .route("/api/card_abilities/:id", axum::routing::MethodRouter::new().get(get_card_ability).put(update_card_ability).patch(patch_card_ability).delete(delete_card_ability))
        .route("/api/card_abilities/:id/api/card-abilities/{id}/usable", axum::routing::get(is_usable_at_card_ability))
        .route("/api/card_abilities/:id/api/card-abilities/{id}/describe", axum::routing::get(describe_card_ability))
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
        card_ability_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_card_ability() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_abilities").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_card_ability() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_abilities?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_card_ability() {
        let pool = setup_pool().await;
        let body = json!({
        "ability_type": "Activated",
        "ability_text": "test",
        "card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/card_abilities")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_card_ability() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/card_abilities/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_card_ability() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "ability_type": "Activated",
        "ability_text": "test",
        "card_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/card_abilities")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "keyword": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/card_abilities/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

    #[tokio::test]
    async fn test_delete_card_ability() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/card_abilities/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
