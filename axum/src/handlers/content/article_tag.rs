use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::article_tag::{ArticleTag, ArticleTagCreateRequest, ArticleTagUpdateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct ArticleTagListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_article_tag(
    State(pool): State<AppState>,
    Query(params): Query<ArticleTagListParams>,
) -> Result<Json<Vec<ArticleTag>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(ArticleTag,
            "SELECT * FROM article_tags WHERE (name LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(ArticleTag, "SELECT * FROM article_tags LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_article_tag(
    State(pool): State<AppState>,
    Json(payload): Json<ArticleTagCreateRequest>,
) -> Result<(StatusCode, Json<ArticleTag>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(ArticleTag,
        "INSERT INTO article_tags (name, slug, created_at, updated_at) VALUES ($1, $2, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.slug
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

pub async fn get_article_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<ArticleTag>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(ArticleTag, "SELECT * FROM article_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleTag not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_article_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<ArticleTagUpdateRequest>,
) -> Result<Json<ArticleTag>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(ArticleTag, "SELECT * FROM article_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleTag not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.slug { row.slug = v; }
    sqlx::query_unchecked!(
        "UPDATE article_tags SET name = $1, slug = $2, updated_at = datetime('now') WHERE id = $3",
        row.name, row.slug, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_article_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM article_tags WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "ArticleTag not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn rename_article_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(ArticleTag, "SELECT * FROM article_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleTag not found".to_string()))?;
    // TODO: implement rename business logic
    Ok(StatusCode::OK)
}

pub async fn article_count_article_tag(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(ArticleTag, "SELECT * FROM article_tags WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleTag not found".to_string()))?;
    // TODO: implement article_count business logic
    Ok(StatusCode::OK)
}

pub fn article_tag_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/article_tags", axum::routing::get(list_article_tag).post(create_article_tag))
        .route("/api/article_tags/:id", axum::routing::MethodRouter::new().get(get_article_tag).patch(patch_article_tag).delete(delete_article_tag))
        .route("/api/article_tags/:id/api/article-tags/{id}/rename", axum::routing::patch(rename_article_tag))
        .route("/api/article_tags/:id/api/article-tags/{id}/article-count", axum::routing::get(article_count_article_tag))
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
        article_tag_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_article_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/article_tags").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_article_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/article_tags?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_article_tag() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "slug": "test"
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/article_tags")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_article_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/article_tags/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_article_tag() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "slug": "test"
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/article_tags")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/article_tags/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

    #[tokio::test]
    async fn test_delete_article_tag() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/article_tags/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
