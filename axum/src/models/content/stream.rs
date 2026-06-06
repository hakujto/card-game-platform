#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum StreamStatus {
    Scheduled,
    Live,
    Ended,
}

impl StreamStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            StreamStatus::Scheduled => "Scheduled",
            StreamStatus::Live => "Live",
            StreamStatus::Ended => "Ended",
        }
    }
}

impl std::fmt::Display for StreamStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for StreamStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Scheduled" => Ok(StreamStatus::Scheduled),
            "Live" => Ok(StreamStatus::Live),
            "Ended" => Ok(StreamStatus::Ended),
            _ => Err(format!("unknown StreamStatus: {}", s)),
        }
    }
}

impl From<String> for StreamStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid StreamStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum StreamPlatform {
    Twitch,
    YouTube,
    KickStream,
    Platform,
}

impl StreamPlatform {
    pub fn as_str(&self) -> &'static str {
        match self {
            StreamPlatform::Twitch => "Twitch",
            StreamPlatform::YouTube => "YouTube",
            StreamPlatform::KickStream => "KickStream",
            StreamPlatform::Platform => "Platform",
        }
    }
}

impl std::fmt::Display for StreamPlatform {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for StreamPlatform {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Twitch" => Ok(StreamPlatform::Twitch),
            "YouTube" => Ok(StreamPlatform::YouTube),
            "KickStream" => Ok(StreamPlatform::KickStream),
            "Platform" => Ok(StreamPlatform::Platform),
            _ => Err(format!("unknown StreamPlatform: {}", s)),
        }
    }
}

impl From<String> for StreamPlatform {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid StreamPlatform: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum StreamLanguage {
    EN,
    DE,
    FR,
    IT,
    ES,
    JP,
    PT,
}

impl StreamLanguage {
    pub fn as_str(&self) -> &'static str {
        match self {
            StreamLanguage::EN => "EN",
            StreamLanguage::DE => "DE",
            StreamLanguage::FR => "FR",
            StreamLanguage::IT => "IT",
            StreamLanguage::ES => "ES",
            StreamLanguage::JP => "JP",
            StreamLanguage::PT => "PT",
        }
    }
}

impl std::fmt::Display for StreamLanguage {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for StreamLanguage {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "EN" => Ok(StreamLanguage::EN),
            "DE" => Ok(StreamLanguage::DE),
            "FR" => Ok(StreamLanguage::FR),
            "IT" => Ok(StreamLanguage::IT),
            "ES" => Ok(StreamLanguage::ES),
            "JP" => Ok(StreamLanguage::JP),
            "PT" => Ok(StreamLanguage::PT),
            _ => Err(format!("unknown StreamLanguage: {}", s)),
        }
    }
}

impl From<String> for StreamLanguage {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid StreamLanguage: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Stream {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub title: String,
    pub stream_url: String,
    pub status: StreamStatus,
    pub platform: StreamPlatform,
    pub language: StreamLanguage,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_official: i64,
    pub viewer_count_peak: i64,
    #[serde(rename = "scheduledStart")]
    pub scheduled_start: String,
    #[serde(rename = "actualStart")]
    pub actual_start: Option<String>,
    #[serde(rename = "endedAt")]
    pub ended_at: Option<String>,
    pub vod_url: Option<String>,
    pub tournament_id: Option<i64>,
    pub streamer_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct StreamCreateRequest {
    pub title: String,
    pub stream_url: String,
    pub status: StreamStatus,
    pub platform: StreamPlatform,
    pub language: StreamLanguage,
    pub is_official: bool,
    pub viewer_count_peak: i64,
    pub scheduled_start: String,
    pub actual_start: Option<String>,
    pub ended_at: Option<String>,
    pub vod_url: Option<String>,
    pub tournament_id: Option<i64>,
    pub streamer_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct StreamUpdateRequest {
    pub title: Option<String>,
    pub stream_url: Option<String>,
    pub status: Option<StreamStatus>,
    pub platform: Option<StreamPlatform>,
    pub language: Option<StreamLanguage>,
    pub is_official: Option<bool>,
    pub viewer_count_peak: Option<i64>,
    pub scheduled_start: Option<String>,
    pub actual_start: Option<String>,
    pub ended_at: Option<String>,
    pub vod_url: Option<String>,
    pub tournament_id: Option<i64>,
    pub streamer_id: Option<i64>,
}

impl Stream {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Scheduled", "Live"),
            ("Live", "Ended"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
