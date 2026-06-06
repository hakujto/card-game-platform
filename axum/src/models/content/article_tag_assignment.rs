#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct ArticleTagAssignment {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub article_id: i64,
    pub tag_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct ArticleTagAssignmentCreateRequest {
    pub article_id: i64,
    pub tag_id: i64,
}
