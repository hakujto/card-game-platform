#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentJudgeRole {
    HeadJudge,
    Judge,
    ScorekeeperJudge,
}

impl TournamentJudgeRole {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentJudgeRole::HeadJudge => "HeadJudge",
            TournamentJudgeRole::Judge => "Judge",
            TournamentJudgeRole::ScorekeeperJudge => "ScorekeeperJudge",
        }
    }
}

impl std::fmt::Display for TournamentJudgeRole {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentJudgeRole {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "HeadJudge" => Ok(TournamentJudgeRole::HeadJudge),
            "Judge" => Ok(TournamentJudgeRole::Judge),
            "ScorekeeperJudge" => Ok(TournamentJudgeRole::ScorekeeperJudge),
            _ => Err(format!("unknown TournamentJudgeRole: {}", s)),
        }
    }
}

impl From<String> for TournamentJudgeRole {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentJudgeRole: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TournamentJudge {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub role: TournamentJudgeRole,
    pub tournament_id: i64,
    pub player_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentJudgeCreateRequest {
    pub role: TournamentJudgeRole,
    pub tournament_id: i64,
    pub player_id: i64,
}
