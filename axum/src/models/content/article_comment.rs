#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct ArticleComment {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub body: String,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_hidden: i64,
    pub article_id: i64,
    pub author_id: i64,
    pub parent_comment_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct ArticleCommentCreateRequest {
    pub body: String,
    pub is_hidden: bool,
    pub article_id: i64,
    pub author_id: i64,
    pub parent_comment_id: Option<i64>,
}
