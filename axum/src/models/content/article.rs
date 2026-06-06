#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum ArticleStatus {
    Draft,
    Published,
    Archived,
}

impl ArticleStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            ArticleStatus::Draft => "Draft",
            ArticleStatus::Published => "Published",
            ArticleStatus::Archived => "Archived",
        }
    }
}

impl std::fmt::Display for ArticleStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for ArticleStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Draft" => Ok(ArticleStatus::Draft),
            "Published" => Ok(ArticleStatus::Published),
            "Archived" => Ok(ArticleStatus::Archived),
            _ => Err(format!("unknown ArticleStatus: {}", s)),
        }
    }
}

impl From<String> for ArticleStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid ArticleStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum ArticleArticleType {
    Guide,
    Tierlist,
    Matchup,
    News,
    Spotlight,
    Decklist,
}

impl ArticleArticleType {
    pub fn as_str(&self) -> &'static str {
        match self {
            ArticleArticleType::Guide => "Guide",
            ArticleArticleType::Tierlist => "Tierlist",
            ArticleArticleType::Matchup => "Matchup",
            ArticleArticleType::News => "News",
            ArticleArticleType::Spotlight => "Spotlight",
            ArticleArticleType::Decklist => "Decklist",
        }
    }
}

impl std::fmt::Display for ArticleArticleType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for ArticleArticleType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Guide" => Ok(ArticleArticleType::Guide),
            "Tierlist" => Ok(ArticleArticleType::Tierlist),
            "Matchup" => Ok(ArticleArticleType::Matchup),
            "News" => Ok(ArticleArticleType::News),
            "Spotlight" => Ok(ArticleArticleType::Spotlight),
            "Decklist" => Ok(ArticleArticleType::Decklist),
            _ => Err(format!("unknown ArticleArticleType: {}", s)),
        }
    }
}

impl From<String> for ArticleArticleType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid ArticleArticleType: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum ArticleLanguage {
    EN,
    DE,
    FR,
    IT,
    ES,
    JP,
    PT,
}

impl ArticleLanguage {
    pub fn as_str(&self) -> &'static str {
        match self {
            ArticleLanguage::EN => "EN",
            ArticleLanguage::DE => "DE",
            ArticleLanguage::FR => "FR",
            ArticleLanguage::IT => "IT",
            ArticleLanguage::ES => "ES",
            ArticleLanguage::JP => "JP",
            ArticleLanguage::PT => "PT",
        }
    }
}

impl std::fmt::Display for ArticleLanguage {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for ArticleLanguage {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "EN" => Ok(ArticleLanguage::EN),
            "DE" => Ok(ArticleLanguage::DE),
            "FR" => Ok(ArticleLanguage::FR),
            "IT" => Ok(ArticleLanguage::IT),
            "ES" => Ok(ArticleLanguage::ES),
            "JP" => Ok(ArticleLanguage::JP),
            "PT" => Ok(ArticleLanguage::PT),
            _ => Err(format!("unknown ArticleLanguage: {}", s)),
        }
    }
}

impl From<String> for ArticleLanguage {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid ArticleLanguage: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Article {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub title: String,
    pub slug: String,
    pub body: String,
    pub excerpt: Option<String>,
    pub cover_image_url: Option<String>,
    pub status: ArticleStatus,
    pub article_type: ArticleArticleType,
    pub language: ArticleLanguage,
    pub view_count: i64,
    pub likes_count: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_featured: i64,
    #[serde(rename = "publishedAt")]
    pub published_at: Option<String>,
    pub author_id: i64,
    pub featured_deck_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct ArticleCreateRequest {
    pub title: String,
    pub slug: String,
    pub body: String,
    pub excerpt: Option<String>,
    pub cover_image_url: Option<String>,
    pub status: ArticleStatus,
    pub article_type: ArticleArticleType,
    pub language: ArticleLanguage,
    pub view_count: i64,
    pub likes_count: i64,
    pub is_featured: bool,
    pub published_at: Option<String>,
    pub author_id: i64,
    pub featured_deck_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct ArticleUpdateRequest {
    pub title: Option<String>,
    pub slug: Option<String>,
    pub body: Option<String>,
    pub excerpt: Option<String>,
    pub cover_image_url: Option<String>,
    pub status: Option<ArticleStatus>,
    pub article_type: Option<ArticleArticleType>,
    pub language: Option<ArticleLanguage>,
    pub view_count: Option<i64>,
    pub likes_count: Option<i64>,
    pub is_featured: Option<bool>,
    pub published_at: Option<String>,
    pub author_id: Option<i64>,
    pub featured_deck_id: Option<i64>,
}

impl Article {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Draft", "Published"),
            ("Published", "Archived"),
            ("Archived", "Draft"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
