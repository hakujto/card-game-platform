#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum GameWinnerSide {
    Player1,
    Player2,
    Draw,
}

impl GameWinnerSide {
    pub fn as_str(&self) -> &'static str {
        match self {
            GameWinnerSide::Player1 => "Player1",
            GameWinnerSide::Player2 => "Player2",
            GameWinnerSide::Draw => "Draw",
        }
    }
}

impl std::fmt::Display for GameWinnerSide {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for GameWinnerSide {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Player1" => Ok(GameWinnerSide::Player1),
            "Player2" => Ok(GameWinnerSide::Player2),
            "Draw" => Ok(GameWinnerSide::Draw),
            _ => Err(format!("unknown GameWinnerSide: {}", s)),
        }
    }
}

impl From<String> for GameWinnerSide {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid GameWinnerSide: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum GameEndedBy {
    Normal,
    Timeout,
    Concession,
    DrawOffer,
}

impl GameEndedBy {
    pub fn as_str(&self) -> &'static str {
        match self {
            GameEndedBy::Normal => "Normal",
            GameEndedBy::Timeout => "Timeout",
            GameEndedBy::Concession => "Concession",
            GameEndedBy::DrawOffer => "DrawOffer",
        }
    }
}

impl std::fmt::Display for GameEndedBy {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for GameEndedBy {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Normal" => Ok(GameEndedBy::Normal),
            "Timeout" => Ok(GameEndedBy::Timeout),
            "Concession" => Ok(GameEndedBy::Concession),
            "DrawOffer" => Ok(GameEndedBy::DrawOffer),
            _ => Err(format!("unknown GameEndedBy: {}", s)),
        }
    }
}

impl From<String> for GameEndedBy {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid GameEndedBy: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Game {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub game_number: i64,
    pub winner_side: Option<GameWinnerSide>,
    pub turns_played: Option<i64>,
    pub duration_seconds: Option<i64>,
    pub ended_by: Option<GameEndedBy>,
    pub replay_url: Option<String>,
    pub match_id: i64,
    pub winner_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct GameCreateRequest {
    pub game_number: i64,
    pub winner_side: Option<GameWinnerSide>,
    pub turns_played: Option<i64>,
    pub duration_seconds: Option<i64>,
    pub ended_by: Option<GameEndedBy>,
    pub replay_url: Option<String>,
    pub match_id: i64,
    pub winner_id: Option<i64>,
}
