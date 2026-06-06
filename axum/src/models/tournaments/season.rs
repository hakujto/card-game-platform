#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum SeasonFormat {
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft,
}

impl SeasonFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            SeasonFormat::Standard => "Standard",
            SeasonFormat::Extended => "Extended",
            SeasonFormat::Legacy => "Legacy",
            SeasonFormat::Vintage => "Vintage",
            SeasonFormat::Commander => "Commander",
            SeasonFormat::Draft => "Draft",
        }
    }
}

impl std::fmt::Display for SeasonFormat {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for SeasonFormat {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Standard" => Ok(SeasonFormat::Standard),
            "Extended" => Ok(SeasonFormat::Extended),
            "Legacy" => Ok(SeasonFormat::Legacy),
            "Vintage" => Ok(SeasonFormat::Vintage),
            "Commander" => Ok(SeasonFormat::Commander),
            "Draft" => Ok(SeasonFormat::Draft),
            _ => Err(format!("unknown SeasonFormat: {}", s)),
        }
    }
}

impl From<String> for SeasonFormat {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid SeasonFormat: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Season {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub start_date: String,
    pub end_date: String,
    pub format: SeasonFormat,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_active: i64,
    pub reward_description: Option<String>,
}

#[derive(Debug, serde::Deserialize)]
pub struct SeasonCreateRequest {
    pub name: String,
    pub start_date: String,
    pub end_date: String,
    pub format: SeasonFormat,
    pub is_active: bool,
    pub reward_description: Option<String>,
}

#[derive(Debug, serde::Deserialize)]
pub struct SeasonUpdateRequest {
    pub name: Option<String>,
    pub start_date: Option<String>,
    pub end_date: Option<String>,
    pub format: Option<SeasonFormat>,
    pub is_active: Option<bool>,
    pub reward_description: Option<String>,
}
