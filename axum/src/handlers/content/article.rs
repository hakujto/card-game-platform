use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::article::{Article, ArticleCreateRequest, ArticleUpdateRequest, ArticleStatus};

type AppState = SqlitePool;

fn validate_article(payload: &ArticleCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.status == ArticleStatus::Published) || payload.published_at.is_some())) { errors.push("Published article must have a published_at timestamp".to_string()); }
    if !(payload.view_count >= 0) { errors.push("Article view count must not be negative".to_string()); }
    if !(payload.likes_count >= 0) { errors.push("Article likes count must not be negative".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct ArticleListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_article(
    State(pool): State<AppState>,
    Query(params): Query<ArticleListParams>,
) -> Result<Json<Vec<Article>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Article,
            "SELECT * FROM articles WHERE (title LIKE '%' || $3 || '%' OR excerpt LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Article, "SELECT * FROM articles LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_article(
    State(pool): State<AppState>,
    Json(payload): Json<ArticleCreateRequest>,
) -> Result<(StatusCode, Json<Article>), (StatusCode, String)> {
    let errors = validate_article(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Article,
        "INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, datetime('now'), datetime('now')) RETURNING *",
        payload.title, payload.slug, payload.body, payload.excerpt, payload.cover_image_url, payload.status, payload.article_type, payload.language, payload.view_count, payload.likes_count, payload.is_featured, payload.published_at, payload.author_id, payload.featured_deck_id
    ).fetch_one(&pool).await
    .map_err(|e| {
        // @unique fields: slug
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Article>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<ArticleCreateRequest>,
) -> Result<Json<Article>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Article,
        "UPDATE articles SET title = $1, slug = $2, body = $3, excerpt = $4, cover_image_url = $5, status = $6, article_type = $7, language = $8, view_count = $9, likes_count = $10, is_featured = $11, published_at = $12, author_id = $13, featured_deck_id = $14, updated_at = datetime('now') WHERE id = $15 RETURNING *",
        payload.title, payload.slug, payload.body, payload.excerpt, payload.cover_image_url, payload.status, payload.article_type, payload.language, payload.view_count, payload.likes_count, payload.is_featured, payload.published_at, payload.author_id, payload.featured_deck_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<ArticleUpdateRequest>,
) -> Result<Json<Article>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    if let Some(v) = payload.title { row.title = v; }
    if let Some(v) = payload.slug { row.slug = v; }
    if let Some(v) = payload.body { row.body = v; }
    if let Some(v) = payload.excerpt { row.excerpt = Some(v); }
    if let Some(v) = payload.cover_image_url { row.cover_image_url = Some(v); }
    if let Some(v) = payload.status { row.status = v; }
    if let Some(v) = payload.article_type { row.article_type = v; }
    if let Some(v) = payload.language { row.language = v; }
    if let Some(v) = payload.view_count { row.view_count = v; }
    if let Some(v) = payload.likes_count { row.likes_count = v; }
    if let Some(v) = payload.is_featured { row.is_featured = v as i64; }
    if let Some(v) = payload.published_at { row.published_at = Some(v); }
    if let Some(v) = payload.author_id { row.author_id = v; }
    if let Some(v) = payload.featured_deck_id { row.featured_deck_id = Some(v); }
    sqlx::query_unchecked!(
        "UPDATE articles SET title = $1, slug = $2, body = $3, excerpt = $4, cover_image_url = $5, status = $6, article_type = $7, language = $8, view_count = $9, likes_count = $10, is_featured = $11, published_at = $12, author_id = $13, featured_deck_id = $14, updated_at = datetime('now') WHERE id = $15",
        row.title, row.slug, row.body, row.excerpt, row.cover_image_url, row.status, row.article_type, row.language, row.view_count, row.likes_count, row.is_featured, row.published_at, row.author_id, row.featured_deck_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn publish_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    // TODO: implement publish business logic
    Ok(StatusCode::OK)
}

pub async fn archive_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    // TODO: implement archive business logic
    Ok(StatusCode::OK)
}

pub async fn increment_view_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    // TODO: implement increment_view business logic
    Ok(StatusCode::OK)
}

pub async fn like_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    // TODO: implement like business logic
    Ok(StatusCode::OK)
}

pub async fn unlike_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    // TODO: implement unlike business logic
    Ok(StatusCode::OK)
}

pub async fn reading_time_minutes_article(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    // TODO: implement reading_time_minutes business logic
    Ok(StatusCode::OK)
}

pub async fn transition_article_draft_to_published(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Article>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    row.assert_transition("Published").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Article,
        "UPDATE articles SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Published", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_article_published_to_archived(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Article>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    row.assert_transition("Archived").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Article,
        "UPDATE articles SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Archived", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_article_archived_to_draft(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Article>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Article, "SELECT * FROM articles WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Article not found".to_string()))?;
    row.assert_transition("Draft").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Article,
        "UPDATE articles SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Draft", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
#[allow(dead_code)]
fn hook_update_search_index(_row: &Article) {
    // TODO: implement update_search_index
}

pub fn article_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/articles", axum::routing::get(list_article).post(create_article))
        .route("/api/articles/:id", axum::routing::MethodRouter::new().get(get_article).put(update_article).patch(patch_article))
        .route("/api/articles/:id/publish", axum::routing::post(publish_article))
        .route("/api/articles/:id/archive", axum::routing::post(archive_article))
        .route("/api/articles/:id/view", axum::routing::post(increment_view_article))
        .route("/api/articles/:id/like", axum::routing::post(like_article))
        .route("/api/articles/:id/like", axum::routing::delete(unlike_article))
        .route("/api/articles/:id/reading-time", axum::routing::get(reading_time_minutes_article))
        .route("/api/articles/:id/transitions/draft-to-published", axum::routing::patch(transition_article_draft_to_published))
        .route("/api/articles/:id/transitions/published-to-archived", axum::routing::patch(transition_article_published_to_archived))
        .route("/api/articles/:id/transitions/archived-to-draft", axum::routing::patch(transition_article_archived_to_draft))
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
        article_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_article() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/articles").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_article() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/articles?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_article() {
        let pool = setup_pool().await;
        let body = json!({
        "title": "test",
        "slug": "test",
        "body": "test",
        "status": "Draft",
        "article_type": "Guide",
        "language": "EN",
        "view_count": 2,
        "likes_count": 2,
        "is_featured": false,
        "author_id": 1,
        "featured_deck_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/articles")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_article() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/articles/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_article() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "title": "test",
        "slug": "test",
        "body": "test",
        "status": "Draft",
        "article_type": "Guide",
        "language": "EN",
        "view_count": 2,
        "likes_count": 2,
        "is_featured": false,
        "author_id": 1,
        "featured_deck_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/articles")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "title": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/articles/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
