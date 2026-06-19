use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::article_comment::{ArticleComment, ArticleCommentCreateRequest};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct ArticleCommentListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_article_comment(
    State(pool): State<AppState>,
    Query(params): Query<ArticleCommentListParams>,
) -> Result<Json<Vec<ArticleComment>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(ArticleComment, "SELECT * FROM article_comments LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_article_comment(
    State(pool): State<AppState>,
    Json(payload): Json<ArticleCommentCreateRequest>,
) -> Result<(StatusCode, Json<ArticleComment>), (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(ArticleComment,
        "INSERT INTO article_comments (body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, datetime('now'), datetime('now')) RETURNING *",
        payload.body, payload.is_hidden, payload.article_id, payload.author_id, payload.parent_comment_id
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

pub async fn get_article_comment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<ArticleComment>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(ArticleComment, "SELECT * FROM article_comments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleComment not found".to_string()))?;
    Ok(Json(row))
}

pub async fn delete_article_comment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM article_comments WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "ArticleComment not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn hide_article_comment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(ArticleComment, "SELECT * FROM article_comments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleComment not found".to_string()))?;
    // TODO: implement hide business logic
    Ok(StatusCode::OK)
}

pub async fn unhide_article_comment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(ArticleComment, "SELECT * FROM article_comments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleComment not found".to_string()))?;
    // TODO: implement unhide business logic
    Ok(StatusCode::OK)
}

pub async fn is_reply_article_comment(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(ArticleComment, "SELECT * FROM article_comments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "ArticleComment not found".to_string()))?;
    // TODO: implement is_reply business logic
    Ok(StatusCode::OK)
}

pub fn article_comment_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/article_comments", axum::routing::get(list_article_comment).post(create_article_comment))
        .route("/api/article_comments/:id", axum::routing::MethodRouter::new().get(get_article_comment).delete(delete_article_comment))
        .route("/api/article_comments/:id/api/comments/{id}/hide", axum::routing::post(hide_article_comment))
        .route("/api/article_comments/:id/api/comments/{id}/unhide", axum::routing::post(unhide_article_comment))
        .route("/api/article_comments/:id/api/comments/{id}/is-reply", axum::routing::get(is_reply_article_comment))
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
        article_comment_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_article_comment() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/article_comments").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_article_comment() {
        let pool = setup_pool().await;
        let body = json!({
        "body": "test",
        "is_hidden": false,
        "article_id": 1,
        "author_id": 1,
        "parent_comment_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/article_comments")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_article_comment() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/article_comments/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_article_comment() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/article_comments/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
