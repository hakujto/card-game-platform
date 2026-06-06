#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct ArticleTag {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub slug: String,
}

#[derive(Debug, serde::Deserialize)]
pub struct ArticleTagCreateRequest {
    pub name: String,
    pub slug: String,
}

#[derive(Debug, serde::Deserialize)]
pub struct ArticleTagUpdateRequest {
    pub name: Option<String>,
    pub slug: Option<String>,
}
