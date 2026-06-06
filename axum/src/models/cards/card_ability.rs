#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardAbilityAbilityType {
    Keyword,
    Activated,
    Triggered,
    Static,
}

impl CardAbilityAbilityType {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardAbilityAbilityType::Keyword => "Keyword",
            CardAbilityAbilityType::Activated => "Activated",
            CardAbilityAbilityType::Triggered => "Triggered",
            CardAbilityAbilityType::Static => "Static",
        }
    }
}

impl std::fmt::Display for CardAbilityAbilityType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardAbilityAbilityType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Keyword" => Ok(CardAbilityAbilityType::Keyword),
            "Activated" => Ok(CardAbilityAbilityType::Activated),
            "Triggered" => Ok(CardAbilityAbilityType::Triggered),
            "Static" => Ok(CardAbilityAbilityType::Static),
            _ => Err(format!("unknown CardAbilityAbilityType: {}", s)),
        }
    }
}

impl From<String> for CardAbilityAbilityType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardAbilityAbilityType: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardAbilityTiming {
    Any,
    Sorcery,
    Instant,
    Combat,
}

impl CardAbilityTiming {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardAbilityTiming::Any => "Any",
            CardAbilityTiming::Sorcery => "Sorcery",
            CardAbilityTiming::Instant => "Instant",
            CardAbilityTiming::Combat => "Combat",
        }
    }
}

impl std::fmt::Display for CardAbilityTiming {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardAbilityTiming {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Any" => Ok(CardAbilityTiming::Any),
            "Sorcery" => Ok(CardAbilityTiming::Sorcery),
            "Instant" => Ok(CardAbilityTiming::Instant),
            "Combat" => Ok(CardAbilityTiming::Combat),
            _ => Err(format!("unknown CardAbilityTiming: {}", s)),
        }
    }
}

impl From<String> for CardAbilityTiming {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardAbilityTiming: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct CardAbility {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub ability_type: CardAbilityAbilityType,
    pub keyword: Option<String>,
    pub ability_text: String,
    pub timing: Option<CardAbilityTiming>,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardAbilityCreateRequest {
    pub ability_type: CardAbilityAbilityType,
    pub keyword: Option<String>,
    pub ability_text: String,
    pub timing: Option<CardAbilityTiming>,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardAbilityUpdateRequest {
    pub ability_type: Option<CardAbilityAbilityType>,
    pub keyword: Option<String>,
    pub ability_text: Option<String>,
    pub timing: Option<CardAbilityTiming>,
    pub card_id: Option<i64>,
}
