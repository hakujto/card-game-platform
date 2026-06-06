#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum FriendshipStatus {
    Pending,
    Accepted,
    Blocked,
}

impl FriendshipStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            FriendshipStatus::Pending => "Pending",
            FriendshipStatus::Accepted => "Accepted",
            FriendshipStatus::Blocked => "Blocked",
        }
    }
}

impl std::fmt::Display for FriendshipStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for FriendshipStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Pending" => Ok(FriendshipStatus::Pending),
            "Accepted" => Ok(FriendshipStatus::Accepted),
            "Blocked" => Ok(FriendshipStatus::Blocked),
            _ => Err(format!("unknown FriendshipStatus: {}", s)),
        }
    }
}

impl From<String> for FriendshipStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid FriendshipStatus: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Friendship {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub status: FriendshipStatus,
    pub requester_id: i64,
    pub receiver_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct FriendshipCreateRequest {
    pub status: FriendshipStatus,
    pub requester_id: i64,
    pub receiver_id: i64,
}
