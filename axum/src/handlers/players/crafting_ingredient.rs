use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::crafting_ingredient::{CraftingIngredient, CraftingIngredientCreateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct CraftingIngredientListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_crafting_ingredient(
    State(pool): State<AppState>,
    Query(params): Query<CraftingIngredientListParams>,
) -> Result<Json<Vec<CraftingIngredient>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(CraftingIngredient, "SELECT * FROM crafting_ingredients LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_crafting_ingredient(
    State(pool): State<AppState>,
    Json(payload): Json<CraftingIngredientCreateRequest>,
) -> Result<(StatusCode, Json<CraftingIngredient>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(CraftingIngredient,
        "INSERT INTO crafting_ingredients (quantity, recipe_id, card_id, created_at, updated_at) VALUES ($1, $2, $3, datetime('now'), datetime('now')) RETURNING *",
        payload.quantity, payload.recipe_id, payload.card_id
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

pub async fn get_crafting_ingredient(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<CraftingIngredient>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(CraftingIngredient, "SELECT * FROM crafting_ingredients WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingIngredient not found".to_string()))
        .map(Json)
}

pub async fn delete_crafting_ingredient(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM crafting_ingredients WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "CraftingIngredient not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub fn crafting_ingredient_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/crafting_ingredients", axum::routing::get(list_crafting_ingredient).post(create_crafting_ingredient))
        .route("/api/crafting_ingredients/:id", axum::routing::MethodRouter::new().get(get_crafting_ingredient).delete(delete_crafting_ingredient))
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
        crafting_ingredient_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_crafting_ingredient() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/crafting_ingredients").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_crafting_ingredient() {
        let pool = setup_pool().await;
        let body = json!({
        "quantity": 2,
        "recipe_id": 1,
        "card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/crafting_ingredients")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_crafting_ingredient() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/crafting_ingredients/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_crafting_ingredient() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/crafting_ingredients/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
