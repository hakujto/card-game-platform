#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentRoundStatus {
    Pending,
    Active,
    Completed,
}

impl TournamentRoundStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentRoundStatus::Pending => "Pending",
            TournamentRoundStatus::Active => "Active",
            TournamentRoundStatus::Completed => "Completed",
        }
    }
}

impl std::fmt::Display for TournamentRoundStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentRoundStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Pending" => Ok(TournamentRoundStatus::Pending),
            "Active" => Ok(TournamentRoundStatus::Active),
            "Completed" => Ok(TournamentRoundStatus::Completed),
            _ => Err(format!("unknown TournamentRoundStatus: {}", s)),
        }
    }
}

impl From<String> for TournamentRoundStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentRoundStatus: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TournamentRound {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub round_number: i64,
    pub status: TournamentRoundStatus,
    #[serde(rename = "startedAt")]
    pub started_at: Option<String>,
    #[serde(rename = "endedAt")]
    pub ended_at: Option<String>,
    pub time_limit_minutes: i64,
    pub tournament_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentRoundCreateRequest {
    pub round_number: i64,
    pub status: TournamentRoundStatus,
    pub started_at: Option<String>,
    pub ended_at: Option<String>,
    pub time_limit_minutes: i64,
    pub tournament_id: i64,
}
