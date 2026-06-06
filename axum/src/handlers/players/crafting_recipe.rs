use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::crafting_recipe::{CraftingRecipe, CraftingRecipeCreateRequest, CraftingRecipeUpdateRequest};

type AppState = SqlitePool;

fn validate_crafting_recipe(payload: &CraftingRecipeCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.dust_cost > 0) { errors.push("Crafting recipe must have a dust cost greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct CraftingRecipeListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_crafting_recipe(
    State(pool): State<AppState>,
    Query(params): Query<CraftingRecipeListParams>,
) -> Result<Json<Vec<CraftingRecipe>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_crafting_recipe(
    State(pool): State<AppState>,
    Json(payload): Json<CraftingRecipeCreateRequest>,
) -> Result<(StatusCode, Json<CraftingRecipe>), (StatusCode, String)> {
    let errors = validate_crafting_recipe(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(CraftingRecipe,
        "INSERT INTO crafting_recipes (dust_cost, is_available, result_card_id, created_at, updated_at) VALUES ($1, $2, $3, datetime('now'), datetime('now')) RETURNING *",
        payload.dust_cost, payload.is_available, payload.result_card_id
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

pub async fn get_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<CraftingRecipe>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))
        .map(Json)
}

pub async fn update_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CraftingRecipeCreateRequest>,
) -> Result<Json<CraftingRecipe>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(CraftingRecipe,
        "UPDATE crafting_recipes SET dust_cost = $1, is_available = $2, result_card_id = $3, updated_at = datetime('now') WHERE id = $4 RETURNING *",
        payload.dust_cost, payload.is_available, payload.result_card_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CraftingRecipeUpdateRequest>,
) -> Result<Json<CraftingRecipe>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))?;
    if let Some(v) = payload.dust_cost { row.dust_cost = v; }
    if let Some(v) = payload.is_available { row.is_available = v as i64; }
    if let Some(v) = payload.result_card_id { row.result_card_id = v; }
    sqlx::query_unchecked!(
        "UPDATE crafting_recipes SET dust_cost = $1, is_available = $2, result_card_id = $3, updated_at = datetime('now') WHERE id = $4",
        row.dust_cost, row.is_available, row.result_card_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn can_craft_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))?;
    // TODO: implement can_craft business logic
    Ok(StatusCode::OK)
}

pub async fn execute_craft_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))?;
    // TODO: implement execute_craft business logic
    Ok(StatusCode::OK)
}

pub async fn disable_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))?;
    // TODO: implement disable business logic
    Ok(StatusCode::OK)
}

pub async fn enable_crafting_recipe(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(CraftingRecipe, "SELECT * FROM crafting_recipes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "CraftingRecipe not found".to_string()))?;
    // TODO: implement enable business logic
    Ok(StatusCode::OK)
}

pub fn crafting_recipe_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/crafting_recipes", axum::routing::get(list_crafting_recipe).post(create_crafting_recipe))
        .route("/api/crafting_recipes/:id", axum::routing::MethodRouter::new().get(get_crafting_recipe).put(update_crafting_recipe).patch(patch_crafting_recipe))
        .route("/api/crafting_recipes/:id/api/crafting-recipes/{id}/can-craft", axum::routing::get(can_craft_crafting_recipe))
        .route("/api/crafting_recipes/:id/api/crafting-recipes/{id}/craft", axum::routing::post(execute_craft_crafting_recipe))
        .route("/api/crafting_recipes/:id/api/crafting-recipes/{id}/disable", axum::routing::post(disable_crafting_recipe))
        .route("/api/crafting_recipes/:id/api/crafting-recipes/{id}/enable", axum::routing::post(enable_crafting_recipe))
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
        crafting_recipe_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_crafting_recipe() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/crafting_recipes").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_crafting_recipe() {
        let pool = setup_pool().await;
        let body = json!({
        "dust_cost": 2,
        "is_available": false,
        "result_card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/crafting_recipes")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_crafting_recipe() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/crafting_recipes/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
