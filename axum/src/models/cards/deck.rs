#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum DeckFormat {
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft,
}

impl DeckFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            DeckFormat::Standard => "Standard",
            DeckFormat::Extended => "Extended",
            DeckFormat::Legacy => "Legacy",
            DeckFormat::Vintage => "Vintage",
            DeckFormat::Commander => "Commander",
            DeckFormat::Draft => "Draft",
        }
    }
}

impl std::fmt::Display for DeckFormat {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for DeckFormat {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Standard" => Ok(DeckFormat::Standard),
            "Extended" => Ok(DeckFormat::Extended),
            "Legacy" => Ok(DeckFormat::Legacy),
            "Vintage" => Ok(DeckFormat::Vintage),
            "Commander" => Ok(DeckFormat::Commander),
            "Draft" => Ok(DeckFormat::Draft),
            _ => Err(format!("unknown DeckFormat: {}", s)),
        }
    }
}

impl From<String> for DeckFormat {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid DeckFormat: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum DeckArchetype {
    Aggro,
    Control,
    Midrange,
    Combo,
    Prison,
    Tempo,
}

impl DeckArchetype {
    pub fn as_str(&self) -> &'static str {
        match self {
            DeckArchetype::Aggro => "Aggro",
            DeckArchetype::Control => "Control",
            DeckArchetype::Midrange => "Midrange",
            DeckArchetype::Combo => "Combo",
            DeckArchetype::Prison => "Prison",
            DeckArchetype::Tempo => "Tempo",
        }
    }
}

impl std::fmt::Display for DeckArchetype {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for DeckArchetype {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Aggro" => Ok(DeckArchetype::Aggro),
            "Control" => Ok(DeckArchetype::Control),
            "Midrange" => Ok(DeckArchetype::Midrange),
            "Combo" => Ok(DeckArchetype::Combo),
            "Prison" => Ok(DeckArchetype::Prison),
            "Tempo" => Ok(DeckArchetype::Tempo),
            _ => Err(format!("unknown DeckArchetype: {}", s)),
        }
    }
}

impl From<String> for DeckArchetype {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid DeckArchetype: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Deck {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub description: Option<String>,
    pub format: DeckFormat,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_public: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_tournament_legal: i64,
    pub archetype: Option<DeckArchetype>,
    pub wins: i64,
    pub losses: i64,
    pub draws: i64,
    pub player_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckCreateRequest {
    pub name: String,
    pub description: Option<String>,
    pub format: DeckFormat,
    pub is_public: bool,
    pub is_tournament_legal: bool,
    pub archetype: Option<DeckArchetype>,
    pub wins: i64,
    pub losses: i64,
    pub draws: i64,
    pub player_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckUpdateRequest {
    pub name: Option<String>,
    pub description: Option<String>,
    pub format: Option<DeckFormat>,
    pub is_public: Option<bool>,
    pub is_tournament_legal: Option<bool>,
    pub archetype: Option<DeckArchetype>,
    pub wins: Option<i64>,
    pub losses: Option<i64>,
    pub draws: Option<i64>,
    pub player_id: Option<i64>,
}
