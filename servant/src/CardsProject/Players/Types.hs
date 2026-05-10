{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.Types where

import Data.Aeson (ToJSON(..), FromJSON(..), toJSON, parseJSON, withText, genericToJSON, genericParseJSON, defaultOptions, Options(..))
import Data.Aeson.Casing (camelCase)
import Data.Text (Text)
import Database.SQLite.Simple (FromRow(..), ToRow(..), field)
import Database.SQLite.Simple.ToField (ToField(..))
import Database.SQLite.Simple.FromField (FromField(..), returnError, ResultError(ConversionFailed))
import Database.SQLite.Simple.Ok (Ok(..))
import GHC.Generics (Generic)

_toCamel :: String -> String
_toCamel = camelCase

data PlayerRankType
  = PlayerRankType_Bronze
  | PlayerRankType_Silver
  | PlayerRankType_Gold
  | PlayerRankType_Platinum
  | PlayerRankType_Diamond
  | PlayerRankType_Master
  | PlayerRankType_Grandmaster
  deriving (Show, Eq, Generic)

instance ToJSON PlayerRankType where
  toJSON v = case v of
    PlayerRankType_Bronze -> toJSON ("Bronze" :: Text)
    PlayerRankType_Silver -> toJSON ("Silver" :: Text)
    PlayerRankType_Gold -> toJSON ("Gold" :: Text)
    PlayerRankType_Platinum -> toJSON ("Platinum" :: Text)
    PlayerRankType_Diamond -> toJSON ("Diamond" :: Text)
    PlayerRankType_Master -> toJSON ("Master" :: Text)
    PlayerRankType_Grandmaster -> toJSON ("Grandmaster" :: Text)
instance FromJSON PlayerRankType where
  parseJSON = withText "PlayerRankType" $ \txt ->
    if txt == "Bronze" then pure PlayerRankType_Bronze
    else if txt == "Silver" then pure PlayerRankType_Silver
    else if txt == "Gold" then pure PlayerRankType_Gold
    else if txt == "Platinum" then pure PlayerRankType_Platinum
    else if txt == "Diamond" then pure PlayerRankType_Diamond
    else if txt == "Master" then pure PlayerRankType_Master
    else if txt == "Grandmaster" then pure PlayerRankType_Grandmaster
    else fail ("Unknown PlayerRankType: " ++ show txt)

instance ToField PlayerRankType where
  toField PlayerRankType_Bronze = toField ("Bronze" :: Text)
  toField PlayerRankType_Silver = toField ("Silver" :: Text)
  toField PlayerRankType_Gold = toField ("Gold" :: Text)
  toField PlayerRankType_Platinum = toField ("Platinum" :: Text)
  toField PlayerRankType_Diamond = toField ("Diamond" :: Text)
  toField PlayerRankType_Master = toField ("Master" :: Text)
  toField PlayerRankType_Grandmaster = toField ("Grandmaster" :: Text)

instance FromField PlayerRankType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Bronze" then return PlayerRankType_Bronze
    else if txt == "Silver" then return PlayerRankType_Silver
    else if txt == "Gold" then return PlayerRankType_Gold
    else if txt == "Platinum" then return PlayerRankType_Platinum
    else if txt == "Diamond" then return PlayerRankType_Diamond
    else if txt == "Master" then return PlayerRankType_Master
    else if txt == "Grandmaster" then return PlayerRankType_Grandmaster
    else returnError ConversionFailed f ("Unknown PlayerRankType: " ++ show txt)

data PlayerPreferredFormatType
  = PlayerPreferredFormatType_Standard
  | PlayerPreferredFormatType_Extended
  | PlayerPreferredFormatType_Legacy
  | PlayerPreferredFormatType_Vintage
  | PlayerPreferredFormatType_Commander
  | PlayerPreferredFormatType_Draft
  deriving (Show, Eq, Generic)

instance ToJSON PlayerPreferredFormatType where
  toJSON v = case v of
    PlayerPreferredFormatType_Standard -> toJSON ("Standard" :: Text)
    PlayerPreferredFormatType_Extended -> toJSON ("Extended" :: Text)
    PlayerPreferredFormatType_Legacy -> toJSON ("Legacy" :: Text)
    PlayerPreferredFormatType_Vintage -> toJSON ("Vintage" :: Text)
    PlayerPreferredFormatType_Commander -> toJSON ("Commander" :: Text)
    PlayerPreferredFormatType_Draft -> toJSON ("Draft" :: Text)
instance FromJSON PlayerPreferredFormatType where
  parseJSON = withText "PlayerPreferredFormatType" $ \txt ->
    if txt == "Standard" then pure PlayerPreferredFormatType_Standard
    else if txt == "Extended" then pure PlayerPreferredFormatType_Extended
    else if txt == "Legacy" then pure PlayerPreferredFormatType_Legacy
    else if txt == "Vintage" then pure PlayerPreferredFormatType_Vintage
    else if txt == "Commander" then pure PlayerPreferredFormatType_Commander
    else if txt == "Draft" then pure PlayerPreferredFormatType_Draft
    else fail ("Unknown PlayerPreferredFormatType: " ++ show txt)

instance ToField PlayerPreferredFormatType where
  toField PlayerPreferredFormatType_Standard = toField ("Standard" :: Text)
  toField PlayerPreferredFormatType_Extended = toField ("Extended" :: Text)
  toField PlayerPreferredFormatType_Legacy = toField ("Legacy" :: Text)
  toField PlayerPreferredFormatType_Vintage = toField ("Vintage" :: Text)
  toField PlayerPreferredFormatType_Commander = toField ("Commander" :: Text)
  toField PlayerPreferredFormatType_Draft = toField ("Draft" :: Text)

instance FromField PlayerPreferredFormatType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Standard" then return PlayerPreferredFormatType_Standard
    else if txt == "Extended" then return PlayerPreferredFormatType_Extended
    else if txt == "Legacy" then return PlayerPreferredFormatType_Legacy
    else if txt == "Vintage" then return PlayerPreferredFormatType_Vintage
    else if txt == "Commander" then return PlayerPreferredFormatType_Commander
    else if txt == "Draft" then return PlayerPreferredFormatType_Draft
    else returnError ConversionFailed f ("Unknown PlayerPreferredFormatType: " ++ show txt)

_playerOpts :: Options
_playerOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 6 }

data Player = Player
  { playerId :: Int
  , playerDisplayName :: Text
  , playerRank :: PlayerRankType
  , playerRating :: Int
  , playerPeakRating :: Int
  , playerBio :: Maybe Text
  , playerCountryCode :: Maybe Text
  , playerAvatarUrl :: Maybe Text
  , playerPreferredFormat :: Maybe PlayerPreferredFormatType
  , playerIsVerified :: Bool
  , playerCreatedAt :: Text
  , playerLastActiveAt :: Maybe Text
  , playerUserId :: Maybe Int
  , playerSeasonStatsId :: Int
  } deriving (Show, Generic)

instance ToJSON Player where
  toJSON = genericToJSON _playerOpts
instance FromJSON Player where
  parseJSON = genericParseJSON _playerOpts

instance FromRow Player where
  fromRow = Player <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newPlayerOpts :: Options
_newPlayerOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data NewPlayer = NewPlayer
  { bPlayerDisplayName :: Text
  , bPlayerRank :: PlayerRankType
  , bPlayerRating :: Int
  , bPlayerPeakRating :: Int
  , bPlayerBio :: Maybe Text
  , bPlayerCountryCode :: Maybe Text
  , bPlayerAvatarUrl :: Maybe Text
  , bPlayerPreferredFormat :: Maybe PlayerPreferredFormatType
  , bPlayerIsVerified :: Bool
  , bPlayerCreatedAt :: Text
  , bPlayerLastActiveAt :: Maybe Text
  , bPlayerUserId :: Maybe Int
  , bPlayerSeasonStatsId :: Int
  } deriving (Show, Generic)

instance ToJSON NewPlayer where
  toJSON = genericToJSON _newPlayerOpts
instance FromJSON NewPlayer where
  parseJSON = genericParseJSON _newPlayerOpts

instance ToRow NewPlayer where
  toRow b = [toField (bPlayerDisplayName b), toField (bPlayerRank b), toField (bPlayerRating b), toField (bPlayerPeakRating b), toField (bPlayerBio b), toField (bPlayerCountryCode b), toField (bPlayerAvatarUrl b), toField (bPlayerPreferredFormat b), toField (bPlayerIsVerified b), toField (bPlayerCreatedAt b), toField (bPlayerLastActiveAt b), toField (bPlayerUserId b), toField (bPlayerSeasonStatsId b)]

data PlayerSeasonStatsHighestRankType
  = PlayerSeasonStatsHighestRankType_Bronze
  | PlayerSeasonStatsHighestRankType_Silver
  | PlayerSeasonStatsHighestRankType_Gold
  | PlayerSeasonStatsHighestRankType_Platinum
  | PlayerSeasonStatsHighestRankType_Diamond
  | PlayerSeasonStatsHighestRankType_Master
  | PlayerSeasonStatsHighestRankType_Grandmaster
  deriving (Show, Eq, Generic)

instance ToJSON PlayerSeasonStatsHighestRankType where
  toJSON v = case v of
    PlayerSeasonStatsHighestRankType_Bronze -> toJSON ("Bronze" :: Text)
    PlayerSeasonStatsHighestRankType_Silver -> toJSON ("Silver" :: Text)
    PlayerSeasonStatsHighestRankType_Gold -> toJSON ("Gold" :: Text)
    PlayerSeasonStatsHighestRankType_Platinum -> toJSON ("Platinum" :: Text)
    PlayerSeasonStatsHighestRankType_Diamond -> toJSON ("Diamond" :: Text)
    PlayerSeasonStatsHighestRankType_Master -> toJSON ("Master" :: Text)
    PlayerSeasonStatsHighestRankType_Grandmaster -> toJSON ("Grandmaster" :: Text)
instance FromJSON PlayerSeasonStatsHighestRankType where
  parseJSON = withText "PlayerSeasonStatsHighestRankType" $ \txt ->
    if txt == "Bronze" then pure PlayerSeasonStatsHighestRankType_Bronze
    else if txt == "Silver" then pure PlayerSeasonStatsHighestRankType_Silver
    else if txt == "Gold" then pure PlayerSeasonStatsHighestRankType_Gold
    else if txt == "Platinum" then pure PlayerSeasonStatsHighestRankType_Platinum
    else if txt == "Diamond" then pure PlayerSeasonStatsHighestRankType_Diamond
    else if txt == "Master" then pure PlayerSeasonStatsHighestRankType_Master
    else if txt == "Grandmaster" then pure PlayerSeasonStatsHighestRankType_Grandmaster
    else fail ("Unknown PlayerSeasonStatsHighestRankType: " ++ show txt)

instance ToField PlayerSeasonStatsHighestRankType where
  toField PlayerSeasonStatsHighestRankType_Bronze = toField ("Bronze" :: Text)
  toField PlayerSeasonStatsHighestRankType_Silver = toField ("Silver" :: Text)
  toField PlayerSeasonStatsHighestRankType_Gold = toField ("Gold" :: Text)
  toField PlayerSeasonStatsHighestRankType_Platinum = toField ("Platinum" :: Text)
  toField PlayerSeasonStatsHighestRankType_Diamond = toField ("Diamond" :: Text)
  toField PlayerSeasonStatsHighestRankType_Master = toField ("Master" :: Text)
  toField PlayerSeasonStatsHighestRankType_Grandmaster = toField ("Grandmaster" :: Text)

instance FromField PlayerSeasonStatsHighestRankType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Bronze" then return PlayerSeasonStatsHighestRankType_Bronze
    else if txt == "Silver" then return PlayerSeasonStatsHighestRankType_Silver
    else if txt == "Gold" then return PlayerSeasonStatsHighestRankType_Gold
    else if txt == "Platinum" then return PlayerSeasonStatsHighestRankType_Platinum
    else if txt == "Diamond" then return PlayerSeasonStatsHighestRankType_Diamond
    else if txt == "Master" then return PlayerSeasonStatsHighestRankType_Master
    else if txt == "Grandmaster" then return PlayerSeasonStatsHighestRankType_Grandmaster
    else returnError ConversionFailed f ("Unknown PlayerSeasonStatsHighestRankType: " ++ show txt)

_playerSeasonStatsOpts :: Options
_playerSeasonStatsOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data PlayerSeasonStats = PlayerSeasonStats
  { playerSeasonStatsId :: Int
  , playerSeasonStatsWins :: Int
  , playerSeasonStatsLosses :: Int
  , playerSeasonStatsDraws :: Int
  , playerSeasonStatsTournamentWins :: Int
  , playerSeasonStatsHighestRank :: Maybe PlayerSeasonStatsHighestRankType
  , playerSeasonStatsSeasonPoints :: Int
  , playerSeasonStatsPlayerId :: Maybe Int
  , playerSeasonStatsSeasonId :: Int
  } deriving (Show, Generic)

instance ToJSON PlayerSeasonStats where
  toJSON = genericToJSON _playerSeasonStatsOpts
instance FromJSON PlayerSeasonStats where
  parseJSON = genericParseJSON _playerSeasonStatsOpts

instance FromRow PlayerSeasonStats where
  fromRow = PlayerSeasonStats <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newPlayerSeasonStatsOpts :: Options
_newPlayerSeasonStatsOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 18 }

data NewPlayerSeasonStats = NewPlayerSeasonStats
  { bPlayerSeasonStatsWins :: Int
  , bPlayerSeasonStatsLosses :: Int
  , bPlayerSeasonStatsDraws :: Int
  , bPlayerSeasonStatsTournamentWins :: Int
  , bPlayerSeasonStatsHighestRank :: Maybe PlayerSeasonStatsHighestRankType
  , bPlayerSeasonStatsSeasonPoints :: Int
  , bPlayerSeasonStatsPlayerId :: Maybe Int
  , bPlayerSeasonStatsSeasonId :: Int
  } deriving (Show, Generic)

instance ToJSON NewPlayerSeasonStats where
  toJSON = genericToJSON _newPlayerSeasonStatsOpts
instance FromJSON NewPlayerSeasonStats where
  parseJSON = genericParseJSON _newPlayerSeasonStatsOpts

instance ToRow NewPlayerSeasonStats where
  toRow b = [toField (bPlayerSeasonStatsWins b), toField (bPlayerSeasonStatsLosses b), toField (bPlayerSeasonStatsDraws b), toField (bPlayerSeasonStatsTournamentWins b), toField (bPlayerSeasonStatsHighestRank b), toField (bPlayerSeasonStatsSeasonPoints b), toField (bPlayerSeasonStatsPlayerId b), toField (bPlayerSeasonStatsSeasonId b)]

data PlayerCollectionConditionType
  = PlayerCollectionConditionType_Mint
  | PlayerCollectionConditionType_NearMint
  | PlayerCollectionConditionType_Excellent
  | PlayerCollectionConditionType_Good
  | PlayerCollectionConditionType_Played
  deriving (Show, Eq, Generic)

instance ToJSON PlayerCollectionConditionType where
  toJSON v = case v of
    PlayerCollectionConditionType_Mint -> toJSON ("Mint" :: Text)
    PlayerCollectionConditionType_NearMint -> toJSON ("NearMint" :: Text)
    PlayerCollectionConditionType_Excellent -> toJSON ("Excellent" :: Text)
    PlayerCollectionConditionType_Good -> toJSON ("Good" :: Text)
    PlayerCollectionConditionType_Played -> toJSON ("Played" :: Text)
instance FromJSON PlayerCollectionConditionType where
  parseJSON = withText "PlayerCollectionConditionType" $ \txt ->
    if txt == "Mint" then pure PlayerCollectionConditionType_Mint
    else if txt == "NearMint" then pure PlayerCollectionConditionType_NearMint
    else if txt == "Excellent" then pure PlayerCollectionConditionType_Excellent
    else if txt == "Good" then pure PlayerCollectionConditionType_Good
    else if txt == "Played" then pure PlayerCollectionConditionType_Played
    else fail ("Unknown PlayerCollectionConditionType: " ++ show txt)

instance ToField PlayerCollectionConditionType where
  toField PlayerCollectionConditionType_Mint = toField ("Mint" :: Text)
  toField PlayerCollectionConditionType_NearMint = toField ("NearMint" :: Text)
  toField PlayerCollectionConditionType_Excellent = toField ("Excellent" :: Text)
  toField PlayerCollectionConditionType_Good = toField ("Good" :: Text)
  toField PlayerCollectionConditionType_Played = toField ("Played" :: Text)

instance FromField PlayerCollectionConditionType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Mint" then return PlayerCollectionConditionType_Mint
    else if txt == "NearMint" then return PlayerCollectionConditionType_NearMint
    else if txt == "Excellent" then return PlayerCollectionConditionType_Excellent
    else if txt == "Good" then return PlayerCollectionConditionType_Good
    else if txt == "Played" then return PlayerCollectionConditionType_Played
    else returnError ConversionFailed f ("Unknown PlayerCollectionConditionType: " ++ show txt)

data PlayerCollectionAcquiredViaType
  = PlayerCollectionAcquiredViaType_Purchase
  | PlayerCollectionAcquiredViaType_Trade
  | PlayerCollectionAcquiredViaType_TournamentReward
  | PlayerCollectionAcquiredViaType_Pack
  | PlayerCollectionAcquiredViaType_Craft
  deriving (Show, Eq, Generic)

instance ToJSON PlayerCollectionAcquiredViaType where
  toJSON v = case v of
    PlayerCollectionAcquiredViaType_Purchase -> toJSON ("Purchase" :: Text)
    PlayerCollectionAcquiredViaType_Trade -> toJSON ("Trade" :: Text)
    PlayerCollectionAcquiredViaType_TournamentReward -> toJSON ("TournamentReward" :: Text)
    PlayerCollectionAcquiredViaType_Pack -> toJSON ("Pack" :: Text)
    PlayerCollectionAcquiredViaType_Craft -> toJSON ("Craft" :: Text)
instance FromJSON PlayerCollectionAcquiredViaType where
  parseJSON = withText "PlayerCollectionAcquiredViaType" $ \txt ->
    if txt == "Purchase" then pure PlayerCollectionAcquiredViaType_Purchase
    else if txt == "Trade" then pure PlayerCollectionAcquiredViaType_Trade
    else if txt == "TournamentReward" then pure PlayerCollectionAcquiredViaType_TournamentReward
    else if txt == "Pack" then pure PlayerCollectionAcquiredViaType_Pack
    else if txt == "Craft" then pure PlayerCollectionAcquiredViaType_Craft
    else fail ("Unknown PlayerCollectionAcquiredViaType: " ++ show txt)

instance ToField PlayerCollectionAcquiredViaType where
  toField PlayerCollectionAcquiredViaType_Purchase = toField ("Purchase" :: Text)
  toField PlayerCollectionAcquiredViaType_Trade = toField ("Trade" :: Text)
  toField PlayerCollectionAcquiredViaType_TournamentReward = toField ("TournamentReward" :: Text)
  toField PlayerCollectionAcquiredViaType_Pack = toField ("Pack" :: Text)
  toField PlayerCollectionAcquiredViaType_Craft = toField ("Craft" :: Text)

instance FromField PlayerCollectionAcquiredViaType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Purchase" then return PlayerCollectionAcquiredViaType_Purchase
    else if txt == "Trade" then return PlayerCollectionAcquiredViaType_Trade
    else if txt == "TournamentReward" then return PlayerCollectionAcquiredViaType_TournamentReward
    else if txt == "Pack" then return PlayerCollectionAcquiredViaType_Pack
    else if txt == "Craft" then return PlayerCollectionAcquiredViaType_Craft
    else returnError ConversionFailed f ("Unknown PlayerCollectionAcquiredViaType: " ++ show txt)

_playerCollectionOpts :: Options
_playerCollectionOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data PlayerCollection = PlayerCollection
  { playerCollectionId :: Int
  , playerCollectionQuantity :: Int
  , playerCollectionFoil :: Bool
  , playerCollectionCondition :: PlayerCollectionConditionType
  , playerCollectionAcquiredAt :: Text
  , playerCollectionAcquiredVia :: PlayerCollectionAcquiredViaType
  , playerCollectionPlayerId :: Int
  , playerCollectionCardId :: Int
  } deriving (Show, Generic)

instance ToJSON PlayerCollection where
  toJSON = genericToJSON _playerCollectionOpts
instance FromJSON PlayerCollection where
  parseJSON = genericParseJSON _playerCollectionOpts

instance FromRow PlayerCollection where
  fromRow = PlayerCollection <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newPlayerCollectionOpts :: Options
_newPlayerCollectionOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data NewPlayerCollection = NewPlayerCollection
  { bPlayerCollectionQuantity :: Int
  , bPlayerCollectionFoil :: Bool
  , bPlayerCollectionCondition :: PlayerCollectionConditionType
  , bPlayerCollectionAcquiredAt :: Text
  , bPlayerCollectionAcquiredVia :: PlayerCollectionAcquiredViaType
  , bPlayerCollectionPlayerId :: Int
  , bPlayerCollectionCardId :: Int
  } deriving (Show, Generic)

instance ToJSON NewPlayerCollection where
  toJSON = genericToJSON _newPlayerCollectionOpts
instance FromJSON NewPlayerCollection where
  parseJSON = genericParseJSON _newPlayerCollectionOpts

instance ToRow NewPlayerCollection where
  toRow b = [toField (bPlayerCollectionQuantity b), toField (bPlayerCollectionFoil b), toField (bPlayerCollectionCondition b), toField (bPlayerCollectionAcquiredAt b), toField (bPlayerCollectionAcquiredVia b), toField (bPlayerCollectionPlayerId b), toField (bPlayerCollectionCardId b)]

data FriendshipStatusType
  = FriendshipStatusType_Pending
  | FriendshipStatusType_Accepted
  | FriendshipStatusType_Blocked
  deriving (Show, Eq, Generic)

instance ToJSON FriendshipStatusType where
  toJSON v = case v of
    FriendshipStatusType_Pending -> toJSON ("Pending" :: Text)
    FriendshipStatusType_Accepted -> toJSON ("Accepted" :: Text)
    FriendshipStatusType_Blocked -> toJSON ("Blocked" :: Text)
instance FromJSON FriendshipStatusType where
  parseJSON = withText "FriendshipStatusType" $ \txt ->
    if txt == "Pending" then pure FriendshipStatusType_Pending
    else if txt == "Accepted" then pure FriendshipStatusType_Accepted
    else if txt == "Blocked" then pure FriendshipStatusType_Blocked
    else fail ("Unknown FriendshipStatusType: " ++ show txt)

instance ToField FriendshipStatusType where
  toField FriendshipStatusType_Pending = toField ("Pending" :: Text)
  toField FriendshipStatusType_Accepted = toField ("Accepted" :: Text)
  toField FriendshipStatusType_Blocked = toField ("Blocked" :: Text)

instance FromField FriendshipStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Pending" then return FriendshipStatusType_Pending
    else if txt == "Accepted" then return FriendshipStatusType_Accepted
    else if txt == "Blocked" then return FriendshipStatusType_Blocked
    else returnError ConversionFailed f ("Unknown FriendshipStatusType: " ++ show txt)

_friendshipOpts :: Options
_friendshipOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 10 }

data Friendship = Friendship
  { friendshipId :: Int
  , friendshipStatus :: FriendshipStatusType
  , friendshipCreatedAt :: Text
  , friendshipRequesterId :: Int
  , friendshipReceiverId :: Int
  } deriving (Show, Generic)

instance ToJSON Friendship where
  toJSON = genericToJSON _friendshipOpts
instance FromJSON Friendship where
  parseJSON = genericParseJSON _friendshipOpts

instance FromRow Friendship where
  fromRow = Friendship <$> field <*> field <*> field <*> field <*> field

_newFriendshipOpts :: Options
_newFriendshipOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 11 }

data NewFriendship = NewFriendship
  { bFriendshipStatus :: FriendshipStatusType
  , bFriendshipCreatedAt :: Text
  , bFriendshipRequesterId :: Int
  , bFriendshipReceiverId :: Int
  } deriving (Show, Generic)

instance ToJSON NewFriendship where
  toJSON = genericToJSON _newFriendshipOpts
instance FromJSON NewFriendship where
  parseJSON = genericParseJSON _newFriendshipOpts

instance ToRow NewFriendship where
  toRow b = [toField (bFriendshipStatus b), toField (bFriendshipCreatedAt b), toField (bFriendshipRequesterId b), toField (bFriendshipReceiverId b)]

data AchievementRarityType
  = AchievementRarityType_Common
  | AchievementRarityType_Uncommon
  | AchievementRarityType_Rare
  | AchievementRarityType_Epic
  | AchievementRarityType_Legendary
  deriving (Show, Eq, Generic)

instance ToJSON AchievementRarityType where
  toJSON v = case v of
    AchievementRarityType_Common -> toJSON ("Common" :: Text)
    AchievementRarityType_Uncommon -> toJSON ("Uncommon" :: Text)
    AchievementRarityType_Rare -> toJSON ("Rare" :: Text)
    AchievementRarityType_Epic -> toJSON ("Epic" :: Text)
    AchievementRarityType_Legendary -> toJSON ("Legendary" :: Text)
instance FromJSON AchievementRarityType where
  parseJSON = withText "AchievementRarityType" $ \txt ->
    if txt == "Common" then pure AchievementRarityType_Common
    else if txt == "Uncommon" then pure AchievementRarityType_Uncommon
    else if txt == "Rare" then pure AchievementRarityType_Rare
    else if txt == "Epic" then pure AchievementRarityType_Epic
    else if txt == "Legendary" then pure AchievementRarityType_Legendary
    else fail ("Unknown AchievementRarityType: " ++ show txt)

instance ToField AchievementRarityType where
  toField AchievementRarityType_Common = toField ("Common" :: Text)
  toField AchievementRarityType_Uncommon = toField ("Uncommon" :: Text)
  toField AchievementRarityType_Rare = toField ("Rare" :: Text)
  toField AchievementRarityType_Epic = toField ("Epic" :: Text)
  toField AchievementRarityType_Legendary = toField ("Legendary" :: Text)

instance FromField AchievementRarityType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Common" then return AchievementRarityType_Common
    else if txt == "Uncommon" then return AchievementRarityType_Uncommon
    else if txt == "Rare" then return AchievementRarityType_Rare
    else if txt == "Epic" then return AchievementRarityType_Epic
    else if txt == "Legendary" then return AchievementRarityType_Legendary
    else returnError ConversionFailed f ("Unknown AchievementRarityType: " ++ show txt)

_achievementOpts :: Options
_achievementOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 11 }

data Achievement = Achievement
  { achievementId :: Int
  , achievementName :: Text
  , achievementDescription :: Text
  , achievementIconUrl :: Maybe Text
  , achievementPoints :: Int
  , achievementRarity :: AchievementRarityType
  , achievementIsHidden :: Bool
  } deriving (Show, Generic)

instance ToJSON Achievement where
  toJSON = genericToJSON _achievementOpts
instance FromJSON Achievement where
  parseJSON = genericParseJSON _achievementOpts

instance FromRow Achievement where
  fromRow = Achievement <$> field <*> field <*> field <*> field <*> field <*> field <*> field

_newAchievementOpts :: Options
_newAchievementOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 12 }

data NewAchievement = NewAchievement
  { bAchievementName :: Text
  , bAchievementDescription :: Text
  , bAchievementIconUrl :: Maybe Text
  , bAchievementPoints :: Int
  , bAchievementRarity :: AchievementRarityType
  , bAchievementIsHidden :: Bool
  } deriving (Show, Generic)

instance ToJSON NewAchievement where
  toJSON = genericToJSON _newAchievementOpts
instance FromJSON NewAchievement where
  parseJSON = genericParseJSON _newAchievementOpts

instance ToRow NewAchievement where
  toRow b = [toField (bAchievementName b), toField (bAchievementDescription b), toField (bAchievementIconUrl b), toField (bAchievementPoints b), toField (bAchievementRarity b), toField (bAchievementIsHidden b)]

_playerAchievementOpts :: Options
_playerAchievementOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data PlayerAchievement = PlayerAchievement
  { playerAchievementId :: Int
  , playerAchievementEarnedAt :: Text
  , playerAchievementProgress :: Int
  , playerAchievementIsCompleted :: Bool
  , playerAchievementPlayerId :: Int
  , playerAchievementAchievementId :: Int
  } deriving (Show, Generic)

instance ToJSON PlayerAchievement where
  toJSON = genericToJSON _playerAchievementOpts
instance FromJSON PlayerAchievement where
  parseJSON = genericParseJSON _playerAchievementOpts

instance FromRow PlayerAchievement where
  fromRow = PlayerAchievement <$> field <*> field <*> field <*> field <*> field <*> field

_newPlayerAchievementOpts :: Options
_newPlayerAchievementOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 18 }

data NewPlayerAchievement = NewPlayerAchievement
  { bPlayerAchievementEarnedAt :: Text
  , bPlayerAchievementProgress :: Int
  , bPlayerAchievementIsCompleted :: Bool
  , bPlayerAchievementPlayerId :: Int
  , bPlayerAchievementAchievementId :: Int
  } deriving (Show, Generic)

instance ToJSON NewPlayerAchievement where
  toJSON = genericToJSON _newPlayerAchievementOpts
instance FromJSON NewPlayerAchievement where
  parseJSON = genericParseJSON _newPlayerAchievementOpts

instance ToRow NewPlayerAchievement where
  toRow b = [toField (bPlayerAchievementEarnedAt b), toField (bPlayerAchievementProgress b), toField (bPlayerAchievementIsCompleted b), toField (bPlayerAchievementPlayerId b), toField (bPlayerAchievementAchievementId b)]

_craftingRecipeOpts :: Options
_craftingRecipeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 14 }

data CraftingRecipe = CraftingRecipe
  { craftingRecipeId :: Int
  , craftingRecipeDustCost :: Int
  , craftingRecipeIsAvailable :: Bool
  , craftingRecipeResultCardId :: Int
  } deriving (Show, Generic)

instance ToJSON CraftingRecipe where
  toJSON = genericToJSON _craftingRecipeOpts
instance FromJSON CraftingRecipe where
  parseJSON = genericParseJSON _craftingRecipeOpts

instance FromRow CraftingRecipe where
  fromRow = CraftingRecipe <$> field <*> field <*> field <*> field

_newCraftingRecipeOpts :: Options
_newCraftingRecipeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 15 }

data NewCraftingRecipe = NewCraftingRecipe
  { bCraftingRecipeDustCost :: Int
  , bCraftingRecipeIsAvailable :: Bool
  , bCraftingRecipeResultCardId :: Int
  } deriving (Show, Generic)

instance ToJSON NewCraftingRecipe where
  toJSON = genericToJSON _newCraftingRecipeOpts
instance FromJSON NewCraftingRecipe where
  parseJSON = genericParseJSON _newCraftingRecipeOpts

instance ToRow NewCraftingRecipe where
  toRow b = [toField (bCraftingRecipeDustCost b), toField (bCraftingRecipeIsAvailable b), toField (bCraftingRecipeResultCardId b)]

_craftingIngredientOpts :: Options
_craftingIngredientOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 18 }

data CraftingIngredient = CraftingIngredient
  { craftingIngredientId :: Int
  , craftingIngredientQuantity :: Int
  , craftingIngredientRecipeId :: Int
  , craftingIngredientCardId :: Int
  } deriving (Show, Generic)

instance ToJSON CraftingIngredient where
  toJSON = genericToJSON _craftingIngredientOpts
instance FromJSON CraftingIngredient where
  parseJSON = genericParseJSON _craftingIngredientOpts

instance FromRow CraftingIngredient where
  fromRow = CraftingIngredient <$> field <*> field <*> field <*> field

_newCraftingIngredientOpts :: Options
_newCraftingIngredientOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 19 }

data NewCraftingIngredient = NewCraftingIngredient
  { bCraftingIngredientQuantity :: Int
  , bCraftingIngredientRecipeId :: Int
  , bCraftingIngredientCardId :: Int
  } deriving (Show, Generic)

instance ToJSON NewCraftingIngredient where
  toJSON = genericToJSON _newCraftingIngredientOpts
instance FromJSON NewCraftingIngredient where
  parseJSON = genericParseJSON _newCraftingIngredientOpts

instance ToRow NewCraftingIngredient where
  toRow b = [toField (bCraftingIngredientQuantity b), toField (bCraftingIngredientRecipeId b), toField (bCraftingIngredientCardId b)]

