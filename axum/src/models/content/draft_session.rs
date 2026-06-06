#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum DraftSessionStatus {
    WaitingForPlayers,
    Drafting,
    Completed,
    Abandoned,
}

impl DraftSessionStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            DraftSessionStatus::WaitingForPlayers => "WaitingForPlayers",
            DraftSessionStatus::Drafting => "Drafting",
            DraftSessionStatus::Completed => "Completed",
            DraftSessionStatus::Abandoned => "Abandoned",
        }
    }
}

impl std::fmt::Display for DraftSessionStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for DraftSessionStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "WaitingForPlayers" => Ok(DraftSessionStatus::WaitingForPlayers),
            "Drafting" => Ok(DraftSessionStatus::Drafting),
            "Completed" => Ok(DraftSessionStatus::Completed),
            "Abandoned" => Ok(DraftSessionStatus::Abandoned),
            _ => Err(format!("unknown DraftSessionStatus: {}", s)),
        }
    }
}

impl From<String> for DraftSessionStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid DraftSessionStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum DraftSessionDraftType {
    Booster,
    Cube,
    Rochester,
}

impl DraftSessionDraftType {
    pub fn as_str(&self) -> &'static str {
        match self {
            DraftSessionDraftType::Booster => "Booster",
            DraftSessionDraftType::Cube => "Cube",
            DraftSessionDraftType::Rochester => "Rochester",
        }
    }
}

impl std::fmt::Display for DraftSessionDraftType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for DraftSessionDraftType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Booster" => Ok(DraftSessionDraftType::Booster),
            "Cube" => Ok(DraftSessionDraftType::Cube),
            "Rochester" => Ok(DraftSessionDraftType::Rochester),
            _ => Err(format!("unknown DraftSessionDraftType: {}", s)),
        }
    }
}

impl From<String> for DraftSessionDraftType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid DraftSessionDraftType: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DraftSession {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub status: DraftSessionStatus,
    pub draft_type: DraftSessionDraftType,
    pub seats: i64,
    pub time_per_pick_seconds: i64,
    #[serde(rename = "completedAt")]
    pub completed_at: Option<String>,
    pub card_set_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DraftSessionCreateRequest {
    pub status: DraftSessionStatus,
    pub draft_type: DraftSessionDraftType,
    pub seats: i64,
    pub time_per_pick_seconds: i64,
    pub completed_at: Option<String>,
    pub card_set_id: i64,
}

impl DraftSession {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("WaitingForPlayers", "Drafting"),
            ("Drafting", "Completed"),
            ("Drafting", "Abandoned"),
            ("WaitingForPlayers", "Abandoned"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
