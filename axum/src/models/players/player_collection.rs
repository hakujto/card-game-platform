#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum PlayerCollectionCondition {
    Mint,
    NearMint,
    Excellent,
    Good,
    Played,
}

impl PlayerCollectionCondition {
    pub fn as_str(&self) -> &'static str {
        match self {
            PlayerCollectionCondition::Mint => "Mint",
            PlayerCollectionCondition::NearMint => "NearMint",
            PlayerCollectionCondition::Excellent => "Excellent",
            PlayerCollectionCondition::Good => "Good",
            PlayerCollectionCondition::Played => "Played",
        }
    }
}

impl std::fmt::Display for PlayerCollectionCondition {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for PlayerCollectionCondition {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Mint" => Ok(PlayerCollectionCondition::Mint),
            "NearMint" => Ok(PlayerCollectionCondition::NearMint),
            "Excellent" => Ok(PlayerCollectionCondition::Excellent),
            "Good" => Ok(PlayerCollectionCondition::Good),
            "Played" => Ok(PlayerCollectionCondition::Played),
            _ => Err(format!("unknown PlayerCollectionCondition: {}", s)),
        }
    }
}

impl From<String> for PlayerCollectionCondition {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid PlayerCollectionCondition: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum PlayerCollectionAcquiredVia {
    Purchase,
    Trade,
    TournamentReward,
    Pack,
    Craft,
}

impl PlayerCollectionAcquiredVia {
    pub fn as_str(&self) -> &'static str {
        match self {
            PlayerCollectionAcquiredVia::Purchase => "Purchase",
            PlayerCollectionAcquiredVia::Trade => "Trade",
            PlayerCollectionAcquiredVia::TournamentReward => "TournamentReward",
            PlayerCollectionAcquiredVia::Pack => "Pack",
            PlayerCollectionAcquiredVia::Craft => "Craft",
        }
    }
}

impl std::fmt::Display for PlayerCollectionAcquiredVia {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for PlayerCollectionAcquiredVia {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Purchase" => Ok(PlayerCollectionAcquiredVia::Purchase),
            "Trade" => Ok(PlayerCollectionAcquiredVia::Trade),
            "TournamentReward" => Ok(PlayerCollectionAcquiredVia::TournamentReward),
            "Pack" => Ok(PlayerCollectionAcquiredVia::Pack),
            "Craft" => Ok(PlayerCollectionAcquiredVia::Craft),
            _ => Err(format!("unknown PlayerCollectionAcquiredVia: {}", s)),
        }
    }
}

impl From<String> for PlayerCollectionAcquiredVia {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid PlayerCollectionAcquiredVia: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct PlayerCollection {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub quantity: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub foil: i64,
    pub condition: PlayerCollectionCondition,
    #[serde(rename = "acquiredAt")]
    pub acquired_at: String,
    pub acquired_via: PlayerCollectionAcquiredVia,
    pub player_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct PlayerCollectionCreateRequest {
    pub quantity: i64,
    pub foil: bool,
    pub condition: PlayerCollectionCondition,
    pub acquired_at: String,
    pub acquired_via: PlayerCollectionAcquiredVia,
    pub player_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct PlayerCollectionUpdateRequest {
    pub quantity: Option<i64>,
    pub foil: Option<bool>,
    pub condition: Option<PlayerCollectionCondition>,
    pub acquired_at: Option<String>,
    pub acquired_via: Option<PlayerCollectionAcquiredVia>,
    pub player_id: Option<i64>,
    pub card_id: Option<i64>,
}
