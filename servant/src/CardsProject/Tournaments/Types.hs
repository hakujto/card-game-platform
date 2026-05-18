{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.Types where

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

data SeasonFormatType
  = SeasonFormatType_Standard
  | SeasonFormatType_Extended
  | SeasonFormatType_Legacy
  | SeasonFormatType_Vintage
  | SeasonFormatType_Commander
  | SeasonFormatType_Draft
  deriving (Show, Eq, Generic)

instance ToJSON SeasonFormatType where
  toJSON v = case v of
    SeasonFormatType_Standard -> toJSON ("Standard" :: Text)
    SeasonFormatType_Extended -> toJSON ("Extended" :: Text)
    SeasonFormatType_Legacy -> toJSON ("Legacy" :: Text)
    SeasonFormatType_Vintage -> toJSON ("Vintage" :: Text)
    SeasonFormatType_Commander -> toJSON ("Commander" :: Text)
    SeasonFormatType_Draft -> toJSON ("Draft" :: Text)
instance FromJSON SeasonFormatType where
  parseJSON = withText "SeasonFormatType" $ \txt ->
    if txt == "Standard" then pure SeasonFormatType_Standard
    else if txt == "Extended" then pure SeasonFormatType_Extended
    else if txt == "Legacy" then pure SeasonFormatType_Legacy
    else if txt == "Vintage" then pure SeasonFormatType_Vintage
    else if txt == "Commander" then pure SeasonFormatType_Commander
    else if txt == "Draft" then pure SeasonFormatType_Draft
    else fail ("Unknown SeasonFormatType: " ++ show txt)

instance ToField SeasonFormatType where
  toField SeasonFormatType_Standard = toField ("Standard" :: Text)
  toField SeasonFormatType_Extended = toField ("Extended" :: Text)
  toField SeasonFormatType_Legacy = toField ("Legacy" :: Text)
  toField SeasonFormatType_Vintage = toField ("Vintage" :: Text)
  toField SeasonFormatType_Commander = toField ("Commander" :: Text)
  toField SeasonFormatType_Draft = toField ("Draft" :: Text)

instance FromField SeasonFormatType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Standard" then return SeasonFormatType_Standard
    else if txt == "Extended" then return SeasonFormatType_Extended
    else if txt == "Legacy" then return SeasonFormatType_Legacy
    else if txt == "Vintage" then return SeasonFormatType_Vintage
    else if txt == "Commander" then return SeasonFormatType_Commander
    else if txt == "Draft" then return SeasonFormatType_Draft
    else returnError ConversionFailed f ("Unknown SeasonFormatType: " ++ show txt)

_seasonOpts :: Options
_seasonOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 6 }

data Season = Season
  { seasonId :: Int
  , seasonName :: Text
  , seasonStartDate :: Text
  , seasonEndDate :: Text
  , seasonFormat :: SeasonFormatType
  , seasonIsActive :: Bool
  , seasonRewardDescription :: Maybe Text
  } deriving (Show, Generic)

instance ToJSON Season where
  toJSON = genericToJSON _seasonOpts
instance FromJSON Season where
  parseJSON = genericParseJSON _seasonOpts

instance FromRow Season where
  fromRow = Season <$> field <*> field <*> field <*> field <*> field <*> field <*> field

_newSeasonOpts :: Options
_newSeasonOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data NewSeason = NewSeason
  { bSeasonName :: Text
  , bSeasonStartDate :: Text
  , bSeasonEndDate :: Text
  , bSeasonFormat :: SeasonFormatType
  , bSeasonIsActive :: Bool
  , bSeasonRewardDescription :: Maybe Text
  } deriving (Show, Generic)

instance ToJSON NewSeason where
  toJSON = genericToJSON _newSeasonOpts
instance FromJSON NewSeason where
  parseJSON = genericParseJSON _newSeasonOpts

instance ToRow NewSeason where
  toRow b = [toField (bSeasonName b), toField (bSeasonStartDate b), toField (bSeasonEndDate b), toField (bSeasonFormat b), toField (bSeasonIsActive b), toField (bSeasonRewardDescription b)]

data TournamentFormatType
  = TournamentFormatType_Standard
  | TournamentFormatType_Extended
  | TournamentFormatType_Legacy
  | TournamentFormatType_Vintage
  | TournamentFormatType_Commander
  | TournamentFormatType_Draft
  deriving (Show, Eq, Generic)

instance ToJSON TournamentFormatType where
  toJSON v = case v of
    TournamentFormatType_Standard -> toJSON ("Standard" :: Text)
    TournamentFormatType_Extended -> toJSON ("Extended" :: Text)
    TournamentFormatType_Legacy -> toJSON ("Legacy" :: Text)
    TournamentFormatType_Vintage -> toJSON ("Vintage" :: Text)
    TournamentFormatType_Commander -> toJSON ("Commander" :: Text)
    TournamentFormatType_Draft -> toJSON ("Draft" :: Text)
instance FromJSON TournamentFormatType where
  parseJSON = withText "TournamentFormatType" $ \txt ->
    if txt == "Standard" then pure TournamentFormatType_Standard
    else if txt == "Extended" then pure TournamentFormatType_Extended
    else if txt == "Legacy" then pure TournamentFormatType_Legacy
    else if txt == "Vintage" then pure TournamentFormatType_Vintage
    else if txt == "Commander" then pure TournamentFormatType_Commander
    else if txt == "Draft" then pure TournamentFormatType_Draft
    else fail ("Unknown TournamentFormatType: " ++ show txt)

instance ToField TournamentFormatType where
  toField TournamentFormatType_Standard = toField ("Standard" :: Text)
  toField TournamentFormatType_Extended = toField ("Extended" :: Text)
  toField TournamentFormatType_Legacy = toField ("Legacy" :: Text)
  toField TournamentFormatType_Vintage = toField ("Vintage" :: Text)
  toField TournamentFormatType_Commander = toField ("Commander" :: Text)
  toField TournamentFormatType_Draft = toField ("Draft" :: Text)

instance FromField TournamentFormatType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Standard" then return TournamentFormatType_Standard
    else if txt == "Extended" then return TournamentFormatType_Extended
    else if txt == "Legacy" then return TournamentFormatType_Legacy
    else if txt == "Vintage" then return TournamentFormatType_Vintage
    else if txt == "Commander" then return TournamentFormatType_Commander
    else if txt == "Draft" then return TournamentFormatType_Draft
    else returnError ConversionFailed f ("Unknown TournamentFormatType: " ++ show txt)

data TournamentTournamentTypeType
  = TournamentTournamentTypeType_Swiss
  | TournamentTournamentTypeType_SingleElimination
  | TournamentTournamentTypeType_DoubleElimination
  | TournamentTournamentTypeType_RoundRobin
  deriving (Show, Eq, Generic)

instance ToJSON TournamentTournamentTypeType where
  toJSON v = case v of
    TournamentTournamentTypeType_Swiss -> toJSON ("Swiss" :: Text)
    TournamentTournamentTypeType_SingleElimination -> toJSON ("SingleElimination" :: Text)
    TournamentTournamentTypeType_DoubleElimination -> toJSON ("DoubleElimination" :: Text)
    TournamentTournamentTypeType_RoundRobin -> toJSON ("RoundRobin" :: Text)
instance FromJSON TournamentTournamentTypeType where
  parseJSON = withText "TournamentTournamentTypeType" $ \txt ->
    if txt == "Swiss" then pure TournamentTournamentTypeType_Swiss
    else if txt == "SingleElimination" then pure TournamentTournamentTypeType_SingleElimination
    else if txt == "DoubleElimination" then pure TournamentTournamentTypeType_DoubleElimination
    else if txt == "RoundRobin" then pure TournamentTournamentTypeType_RoundRobin
    else fail ("Unknown TournamentTournamentTypeType: " ++ show txt)

instance ToField TournamentTournamentTypeType where
  toField TournamentTournamentTypeType_Swiss = toField ("Swiss" :: Text)
  toField TournamentTournamentTypeType_SingleElimination = toField ("SingleElimination" :: Text)
  toField TournamentTournamentTypeType_DoubleElimination = toField ("DoubleElimination" :: Text)
  toField TournamentTournamentTypeType_RoundRobin = toField ("RoundRobin" :: Text)

instance FromField TournamentTournamentTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Swiss" then return TournamentTournamentTypeType_Swiss
    else if txt == "SingleElimination" then return TournamentTournamentTypeType_SingleElimination
    else if txt == "DoubleElimination" then return TournamentTournamentTypeType_DoubleElimination
    else if txt == "RoundRobin" then return TournamentTournamentTypeType_RoundRobin
    else returnError ConversionFailed f ("Unknown TournamentTournamentTypeType: " ++ show txt)

data TournamentStatusType
  = TournamentStatusType_Draft
  | TournamentStatusType_Registration
  | TournamentStatusType_Ongoing
  | TournamentStatusType_Completed
  | TournamentStatusType_Cancelled
  deriving (Show, Eq, Generic)

instance ToJSON TournamentStatusType where
  toJSON v = case v of
    TournamentStatusType_Draft -> toJSON ("Draft" :: Text)
    TournamentStatusType_Registration -> toJSON ("Registration" :: Text)
    TournamentStatusType_Ongoing -> toJSON ("Ongoing" :: Text)
    TournamentStatusType_Completed -> toJSON ("Completed" :: Text)
    TournamentStatusType_Cancelled -> toJSON ("Cancelled" :: Text)
instance FromJSON TournamentStatusType where
  parseJSON = withText "TournamentStatusType" $ \txt ->
    if txt == "Draft" then pure TournamentStatusType_Draft
    else if txt == "Registration" then pure TournamentStatusType_Registration
    else if txt == "Ongoing" then pure TournamentStatusType_Ongoing
    else if txt == "Completed" then pure TournamentStatusType_Completed
    else if txt == "Cancelled" then pure TournamentStatusType_Cancelled
    else fail ("Unknown TournamentStatusType: " ++ show txt)

instance ToField TournamentStatusType where
  toField TournamentStatusType_Draft = toField ("Draft" :: Text)
  toField TournamentStatusType_Registration = toField ("Registration" :: Text)
  toField TournamentStatusType_Ongoing = toField ("Ongoing" :: Text)
  toField TournamentStatusType_Completed = toField ("Completed" :: Text)
  toField TournamentStatusType_Cancelled = toField ("Cancelled" :: Text)

instance FromField TournamentStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Draft" then return TournamentStatusType_Draft
    else if txt == "Registration" then return TournamentStatusType_Registration
    else if txt == "Ongoing" then return TournamentStatusType_Ongoing
    else if txt == "Completed" then return TournamentStatusType_Completed
    else if txt == "Cancelled" then return TournamentStatusType_Cancelled
    else returnError ConversionFailed f ("Unknown TournamentStatusType: " ++ show txt)

_tournamentOpts :: Options
_tournamentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 10 }

data Tournament = Tournament
  { tournamentId :: Int
  , tournamentName :: Text
  , tournamentDescription :: Maybe Text
  , tournamentFormat :: TournamentFormatType
  , tournamentTournamentType :: TournamentTournamentTypeType
  , tournamentStatus :: TournamentStatusType
  , tournamentMaxPlayers :: Int
  , tournamentEntryFee :: Text
  , tournamentPrizePool :: Text
  , tournamentStartTime :: Text
  , tournamentEndTime :: Maybe Text
  , tournamentIsOnline :: Bool
  , tournamentLocation :: Maybe Text
  , tournamentRulesText :: Maybe Text
  , tournamentCreatedAt :: Text
  , tournamentSeasonId :: Maybe Int
  , tournamentOrganizerId :: Maybe Int
  , tournamentRegistrationsId :: Maybe Int
  , tournamentRoundsId :: Maybe Int
  , tournamentPrizesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Tournament where
  toJSON = genericToJSON _tournamentOpts
instance FromJSON Tournament where
  parseJSON = genericParseJSON _tournamentOpts

instance FromRow Tournament where
  fromRow = Tournament <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTournamentOpts :: Options
_newTournamentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 11 }

data NewTournament = NewTournament
  { bTournamentName :: Text
  , bTournamentDescription :: Maybe Text
  , bTournamentFormat :: TournamentFormatType
  , bTournamentTournamentType :: TournamentTournamentTypeType
  , bTournamentStatus :: TournamentStatusType
  , bTournamentMaxPlayers :: Int
  , bTournamentEntryFee :: Text
  , bTournamentPrizePool :: Text
  , bTournamentStartTime :: Text
  , bTournamentEndTime :: Maybe Text
  , bTournamentIsOnline :: Bool
  , bTournamentLocation :: Maybe Text
  , bTournamentRulesText :: Maybe Text
  , bTournamentCreatedAt :: Text
  , bTournamentSeasonId :: Maybe Int
  , bTournamentOrganizerId :: Maybe Int
  , bTournamentRegistrationsId :: Maybe Int
  , bTournamentRoundsId :: Maybe Int
  , bTournamentPrizesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTournament where
  toJSON = genericToJSON _newTournamentOpts
instance FromJSON NewTournament where
  parseJSON = genericParseJSON _newTournamentOpts

instance ToRow NewTournament where
  toRow b = [toField (bTournamentName b), toField (bTournamentDescription b), toField (bTournamentFormat b), toField (bTournamentTournamentType b), toField (bTournamentStatus b), toField (bTournamentMaxPlayers b), toField (bTournamentEntryFee b), toField (bTournamentPrizePool b), toField (bTournamentStartTime b), toField (bTournamentEndTime b), toField (bTournamentIsOnline b), toField (bTournamentLocation b), toField (bTournamentRulesText b), toField (bTournamentCreatedAt b), toField (bTournamentSeasonId b), toField (bTournamentOrganizerId b), toField (bTournamentRegistrationsId b), toField (bTournamentRoundsId b), toField (bTournamentPrizesId b)]

data TournamentJudgeRoleType
  = TournamentJudgeRoleType_HeadJudge
  | TournamentJudgeRoleType_Judge
  | TournamentJudgeRoleType_ScorekeeperJudge
  deriving (Show, Eq, Generic)

instance ToJSON TournamentJudgeRoleType where
  toJSON v = case v of
    TournamentJudgeRoleType_HeadJudge -> toJSON ("HeadJudge" :: Text)
    TournamentJudgeRoleType_Judge -> toJSON ("Judge" :: Text)
    TournamentJudgeRoleType_ScorekeeperJudge -> toJSON ("ScorekeeperJudge" :: Text)
instance FromJSON TournamentJudgeRoleType where
  parseJSON = withText "TournamentJudgeRoleType" $ \txt ->
    if txt == "HeadJudge" then pure TournamentJudgeRoleType_HeadJudge
    else if txt == "Judge" then pure TournamentJudgeRoleType_Judge
    else if txt == "ScorekeeperJudge" then pure TournamentJudgeRoleType_ScorekeeperJudge
    else fail ("Unknown TournamentJudgeRoleType: " ++ show txt)

instance ToField TournamentJudgeRoleType where
  toField TournamentJudgeRoleType_HeadJudge = toField ("HeadJudge" :: Text)
  toField TournamentJudgeRoleType_Judge = toField ("Judge" :: Text)
  toField TournamentJudgeRoleType_ScorekeeperJudge = toField ("ScorekeeperJudge" :: Text)

instance FromField TournamentJudgeRoleType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "HeadJudge" then return TournamentJudgeRoleType_HeadJudge
    else if txt == "Judge" then return TournamentJudgeRoleType_Judge
    else if txt == "ScorekeeperJudge" then return TournamentJudgeRoleType_ScorekeeperJudge
    else returnError ConversionFailed f ("Unknown TournamentJudgeRoleType: " ++ show txt)

_tournamentJudgeOpts :: Options
_tournamentJudgeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 15 }

data TournamentJudge = TournamentJudge
  { tournamentJudgeId :: Int
  , tournamentJudgeRole :: TournamentJudgeRoleType
  , tournamentJudgeTournamentId :: Maybe Int
  , tournamentJudgePlayerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TournamentJudge where
  toJSON = genericToJSON _tournamentJudgeOpts
instance FromJSON TournamentJudge where
  parseJSON = genericParseJSON _tournamentJudgeOpts

instance FromRow TournamentJudge where
  fromRow = TournamentJudge <$> field <*> field <*> field <*> field

_newTournamentJudgeOpts :: Options
_newTournamentJudgeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data NewTournamentJudge = NewTournamentJudge
  { bTournamentJudgeRole :: TournamentJudgeRoleType
  , bTournamentJudgeTournamentId :: Maybe Int
  , bTournamentJudgePlayerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTournamentJudge where
  toJSON = genericToJSON _newTournamentJudgeOpts
instance FromJSON NewTournamentJudge where
  parseJSON = genericParseJSON _newTournamentJudgeOpts

instance ToRow NewTournamentJudge where
  toRow b = [toField (bTournamentJudgeRole b), toField (bTournamentJudgeTournamentId b), toField (bTournamentJudgePlayerId b)]

data TournamentRegistrationStatusType
  = TournamentRegistrationStatusType_Registered
  | TournamentRegistrationStatusType_Waitlisted
  | TournamentRegistrationStatusType_Withdrawn
  | TournamentRegistrationStatusType_Disqualified
  deriving (Show, Eq, Generic)

instance ToJSON TournamentRegistrationStatusType where
  toJSON v = case v of
    TournamentRegistrationStatusType_Registered -> toJSON ("Registered" :: Text)
    TournamentRegistrationStatusType_Waitlisted -> toJSON ("Waitlisted" :: Text)
    TournamentRegistrationStatusType_Withdrawn -> toJSON ("Withdrawn" :: Text)
    TournamentRegistrationStatusType_Disqualified -> toJSON ("Disqualified" :: Text)
instance FromJSON TournamentRegistrationStatusType where
  parseJSON = withText "TournamentRegistrationStatusType" $ \txt ->
    if txt == "Registered" then pure TournamentRegistrationStatusType_Registered
    else if txt == "Waitlisted" then pure TournamentRegistrationStatusType_Waitlisted
    else if txt == "Withdrawn" then pure TournamentRegistrationStatusType_Withdrawn
    else if txt == "Disqualified" then pure TournamentRegistrationStatusType_Disqualified
    else fail ("Unknown TournamentRegistrationStatusType: " ++ show txt)

instance ToField TournamentRegistrationStatusType where
  toField TournamentRegistrationStatusType_Registered = toField ("Registered" :: Text)
  toField TournamentRegistrationStatusType_Waitlisted = toField ("Waitlisted" :: Text)
  toField TournamentRegistrationStatusType_Withdrawn = toField ("Withdrawn" :: Text)
  toField TournamentRegistrationStatusType_Disqualified = toField ("Disqualified" :: Text)

instance FromField TournamentRegistrationStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Registered" then return TournamentRegistrationStatusType_Registered
    else if txt == "Waitlisted" then return TournamentRegistrationStatusType_Waitlisted
    else if txt == "Withdrawn" then return TournamentRegistrationStatusType_Withdrawn
    else if txt == "Disqualified" then return TournamentRegistrationStatusType_Disqualified
    else returnError ConversionFailed f ("Unknown TournamentRegistrationStatusType: " ++ show txt)

_tournamentRegistrationOpts :: Options
_tournamentRegistrationOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 22 }

data TournamentRegistration = TournamentRegistration
  { tournamentRegistrationId :: Int
  , tournamentRegistrationStatus :: TournamentRegistrationStatusType
  , tournamentRegistrationSeed :: Maybe Int
  , tournamentRegistrationFinalStanding :: Maybe Int
  , tournamentRegistrationPointsEarned :: Int
  , tournamentRegistrationRegisteredAt :: Text
  , tournamentRegistrationTournamentId :: Maybe Int
  , tournamentRegistrationPlayerId :: Maybe Int
  , tournamentRegistrationDeckId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TournamentRegistration where
  toJSON = genericToJSON _tournamentRegistrationOpts
instance FromJSON TournamentRegistration where
  parseJSON = genericParseJSON _tournamentRegistrationOpts

instance FromRow TournamentRegistration where
  fromRow = TournamentRegistration <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTournamentRegistrationOpts :: Options
_newTournamentRegistrationOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 23 }

data NewTournamentRegistration = NewTournamentRegistration
  { bTournamentRegistrationStatus :: TournamentRegistrationStatusType
  , bTournamentRegistrationSeed :: Maybe Int
  , bTournamentRegistrationFinalStanding :: Maybe Int
  , bTournamentRegistrationPointsEarned :: Int
  , bTournamentRegistrationRegisteredAt :: Text
  , bTournamentRegistrationTournamentId :: Maybe Int
  , bTournamentRegistrationPlayerId :: Maybe Int
  , bTournamentRegistrationDeckId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTournamentRegistration where
  toJSON = genericToJSON _newTournamentRegistrationOpts
instance FromJSON NewTournamentRegistration where
  parseJSON = genericParseJSON _newTournamentRegistrationOpts

instance ToRow NewTournamentRegistration where
  toRow b = [toField (bTournamentRegistrationStatus b), toField (bTournamentRegistrationSeed b), toField (bTournamentRegistrationFinalStanding b), toField (bTournamentRegistrationPointsEarned b), toField (bTournamentRegistrationRegisteredAt b), toField (bTournamentRegistrationTournamentId b), toField (bTournamentRegistrationPlayerId b), toField (bTournamentRegistrationDeckId b)]

data TournamentRoundStatusType
  = TournamentRoundStatusType_Pending
  | TournamentRoundStatusType_Active
  | TournamentRoundStatusType_Completed
  deriving (Show, Eq, Generic)

instance ToJSON TournamentRoundStatusType where
  toJSON v = case v of
    TournamentRoundStatusType_Pending -> toJSON ("Pending" :: Text)
    TournamentRoundStatusType_Active -> toJSON ("Active" :: Text)
    TournamentRoundStatusType_Completed -> toJSON ("Completed" :: Text)
instance FromJSON TournamentRoundStatusType where
  parseJSON = withText "TournamentRoundStatusType" $ \txt ->
    if txt == "Pending" then pure TournamentRoundStatusType_Pending
    else if txt == "Active" then pure TournamentRoundStatusType_Active
    else if txt == "Completed" then pure TournamentRoundStatusType_Completed
    else fail ("Unknown TournamentRoundStatusType: " ++ show txt)

instance ToField TournamentRoundStatusType where
  toField TournamentRoundStatusType_Pending = toField ("Pending" :: Text)
  toField TournamentRoundStatusType_Active = toField ("Active" :: Text)
  toField TournamentRoundStatusType_Completed = toField ("Completed" :: Text)

instance FromField TournamentRoundStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Pending" then return TournamentRoundStatusType_Pending
    else if txt == "Active" then return TournamentRoundStatusType_Active
    else if txt == "Completed" then return TournamentRoundStatusType_Completed
    else returnError ConversionFailed f ("Unknown TournamentRoundStatusType: " ++ show txt)

_tournamentRoundOpts :: Options
_tournamentRoundOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 15 }

data TournamentRound = TournamentRound
  { tournamentRoundId :: Int
  , tournamentRoundRoundNumber :: Int
  , tournamentRoundStatus :: TournamentRoundStatusType
  , tournamentRoundStartedAt :: Maybe Text
  , tournamentRoundEndedAt :: Maybe Text
  , tournamentRoundTimeLimitMinutes :: Int
  , tournamentRoundTournamentId :: Maybe Int
  , tournamentRoundMatchesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TournamentRound where
  toJSON = genericToJSON _tournamentRoundOpts
instance FromJSON TournamentRound where
  parseJSON = genericParseJSON _tournamentRoundOpts

instance FromRow TournamentRound where
  fromRow = TournamentRound <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTournamentRoundOpts :: Options
_newTournamentRoundOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data NewTournamentRound = NewTournamentRound
  { bTournamentRoundRoundNumber :: Int
  , bTournamentRoundStatus :: TournamentRoundStatusType
  , bTournamentRoundStartedAt :: Maybe Text
  , bTournamentRoundEndedAt :: Maybe Text
  , bTournamentRoundTimeLimitMinutes :: Int
  , bTournamentRoundTournamentId :: Maybe Int
  , bTournamentRoundMatchesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTournamentRound where
  toJSON = genericToJSON _newTournamentRoundOpts
instance FromJSON NewTournamentRound where
  parseJSON = genericParseJSON _newTournamentRoundOpts

instance ToRow NewTournamentRound where
  toRow b = [toField (bTournamentRoundRoundNumber b), toField (bTournamentRoundStatus b), toField (bTournamentRoundStartedAt b), toField (bTournamentRoundEndedAt b), toField (bTournamentRoundTimeLimitMinutes b), toField (bTournamentRoundTournamentId b), toField (bTournamentRoundMatchesId b)]

data MatchStatusType
  = MatchStatusType_Pending
  | MatchStatusType_Active
  | MatchStatusType_Completed
  | MatchStatusType_BYE
  | MatchStatusType_Draw
  deriving (Show, Eq, Generic)

instance ToJSON MatchStatusType where
  toJSON v = case v of
    MatchStatusType_Pending -> toJSON ("Pending" :: Text)
    MatchStatusType_Active -> toJSON ("Active" :: Text)
    MatchStatusType_Completed -> toJSON ("Completed" :: Text)
    MatchStatusType_BYE -> toJSON ("BYE" :: Text)
    MatchStatusType_Draw -> toJSON ("Draw" :: Text)
instance FromJSON MatchStatusType where
  parseJSON = withText "MatchStatusType" $ \txt ->
    if txt == "Pending" then pure MatchStatusType_Pending
    else if txt == "Active" then pure MatchStatusType_Active
    else if txt == "Completed" then pure MatchStatusType_Completed
    else if txt == "BYE" then pure MatchStatusType_BYE
    else if txt == "Draw" then pure MatchStatusType_Draw
    else fail ("Unknown MatchStatusType: " ++ show txt)

instance ToField MatchStatusType where
  toField MatchStatusType_Pending = toField ("Pending" :: Text)
  toField MatchStatusType_Active = toField ("Active" :: Text)
  toField MatchStatusType_Completed = toField ("Completed" :: Text)
  toField MatchStatusType_BYE = toField ("BYE" :: Text)
  toField MatchStatusType_Draw = toField ("Draw" :: Text)

instance FromField MatchStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Pending" then return MatchStatusType_Pending
    else if txt == "Active" then return MatchStatusType_Active
    else if txt == "Completed" then return MatchStatusType_Completed
    else if txt == "BYE" then return MatchStatusType_BYE
    else if txt == "Draw" then return MatchStatusType_Draw
    else returnError ConversionFailed f ("Unknown MatchStatusType: " ++ show txt)

_matchOpts :: Options
_matchOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 5 }

data Match = Match
  { matchId :: Int
  , matchTableNumber :: Maybe Int
  , matchStatus :: MatchStatusType
  , matchPlayer1Wins :: Int
  , matchPlayer2Wins :: Int
  , matchStartedAt :: Maybe Text
  , matchEndedAt :: Maybe Text
  , matchResultNotes :: Maybe Text
  , matchRoundId :: Maybe Int
  , matchPlayer1Id :: Maybe Int
  , matchPlayer2Id :: Maybe Int
  , matchGamesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Match where
  toJSON = genericToJSON _matchOpts
instance FromJSON Match where
  parseJSON = genericParseJSON _matchOpts

instance FromRow Match where
  fromRow = Match <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newMatchOpts :: Options
_newMatchOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 6 }

data NewMatch = NewMatch
  { bMatchTableNumber :: Maybe Int
  , bMatchStatus :: MatchStatusType
  , bMatchPlayer1Wins :: Int
  , bMatchPlayer2Wins :: Int
  , bMatchStartedAt :: Maybe Text
  , bMatchEndedAt :: Maybe Text
  , bMatchResultNotes :: Maybe Text
  , bMatchRoundId :: Maybe Int
  , bMatchPlayer1Id :: Maybe Int
  , bMatchPlayer2Id :: Maybe Int
  , bMatchGamesId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewMatch where
  toJSON = genericToJSON _newMatchOpts
instance FromJSON NewMatch where
  parseJSON = genericParseJSON _newMatchOpts

instance ToRow NewMatch where
  toRow b = [toField (bMatchTableNumber b), toField (bMatchStatus b), toField (bMatchPlayer1Wins b), toField (bMatchPlayer2Wins b), toField (bMatchStartedAt b), toField (bMatchEndedAt b), toField (bMatchResultNotes b), toField (bMatchRoundId b), toField (bMatchPlayer1Id b), toField (bMatchPlayer2Id b), toField (bMatchGamesId b)]

data GameWinnerSideType
  = GameWinnerSideType_Player1
  | GameWinnerSideType_Player2
  | GameWinnerSideType_Draw
  deriving (Show, Eq, Generic)

instance ToJSON GameWinnerSideType where
  toJSON v = case v of
    GameWinnerSideType_Player1 -> toJSON ("Player1" :: Text)
    GameWinnerSideType_Player2 -> toJSON ("Player2" :: Text)
    GameWinnerSideType_Draw -> toJSON ("Draw" :: Text)
instance FromJSON GameWinnerSideType where
  parseJSON = withText "GameWinnerSideType" $ \txt ->
    if txt == "Player1" then pure GameWinnerSideType_Player1
    else if txt == "Player2" then pure GameWinnerSideType_Player2
    else if txt == "Draw" then pure GameWinnerSideType_Draw
    else fail ("Unknown GameWinnerSideType: " ++ show txt)

instance ToField GameWinnerSideType where
  toField GameWinnerSideType_Player1 = toField ("Player1" :: Text)
  toField GameWinnerSideType_Player2 = toField ("Player2" :: Text)
  toField GameWinnerSideType_Draw = toField ("Draw" :: Text)

instance FromField GameWinnerSideType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Player1" then return GameWinnerSideType_Player1
    else if txt == "Player2" then return GameWinnerSideType_Player2
    else if txt == "Draw" then return GameWinnerSideType_Draw
    else returnError ConversionFailed f ("Unknown GameWinnerSideType: " ++ show txt)

data GameEndedByType
  = GameEndedByType_Normal
  | GameEndedByType_Timeout
  | GameEndedByType_Concession
  | GameEndedByType_DrawOffer
  deriving (Show, Eq, Generic)

instance ToJSON GameEndedByType where
  toJSON v = case v of
    GameEndedByType_Normal -> toJSON ("Normal" :: Text)
    GameEndedByType_Timeout -> toJSON ("Timeout" :: Text)
    GameEndedByType_Concession -> toJSON ("Concession" :: Text)
    GameEndedByType_DrawOffer -> toJSON ("DrawOffer" :: Text)
instance FromJSON GameEndedByType where
  parseJSON = withText "GameEndedByType" $ \txt ->
    if txt == "Normal" then pure GameEndedByType_Normal
    else if txt == "Timeout" then pure GameEndedByType_Timeout
    else if txt == "Concession" then pure GameEndedByType_Concession
    else if txt == "DrawOffer" then pure GameEndedByType_DrawOffer
    else fail ("Unknown GameEndedByType: " ++ show txt)

instance ToField GameEndedByType where
  toField GameEndedByType_Normal = toField ("Normal" :: Text)
  toField GameEndedByType_Timeout = toField ("Timeout" :: Text)
  toField GameEndedByType_Concession = toField ("Concession" :: Text)
  toField GameEndedByType_DrawOffer = toField ("DrawOffer" :: Text)

instance FromField GameEndedByType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Normal" then return GameEndedByType_Normal
    else if txt == "Timeout" then return GameEndedByType_Timeout
    else if txt == "Concession" then return GameEndedByType_Concession
    else if txt == "DrawOffer" then return GameEndedByType_DrawOffer
    else returnError ConversionFailed f ("Unknown GameEndedByType: " ++ show txt)

_gameOpts :: Options
_gameOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 4 }

data Game = Game
  { gameId :: Int
  , gameGameNumber :: Int
  , gameWinnerSide :: Maybe GameWinnerSideType
  , gameTurnsPlayed :: Maybe Int
  , gameDurationSeconds :: Maybe Int
  , gameEndedBy :: Maybe GameEndedByType
  , gameReplayUrl :: Maybe Text
  , gameMatchId :: Maybe Int
  , gameWinnerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Game where
  toJSON = genericToJSON _gameOpts
instance FromJSON Game where
  parseJSON = genericParseJSON _gameOpts

instance FromRow Game where
  fromRow = Game <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newGameOpts :: Options
_newGameOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 5 }

data NewGame = NewGame
  { bGameGameNumber :: Int
  , bGameWinnerSide :: Maybe GameWinnerSideType
  , bGameTurnsPlayed :: Maybe Int
  , bGameDurationSeconds :: Maybe Int
  , bGameEndedBy :: Maybe GameEndedByType
  , bGameReplayUrl :: Maybe Text
  , bGameMatchId :: Maybe Int
  , bGameWinnerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewGame where
  toJSON = genericToJSON _newGameOpts
instance FromJSON NewGame where
  parseJSON = genericParseJSON _newGameOpts

instance ToRow NewGame where
  toRow b = [toField (bGameGameNumber b), toField (bGameWinnerSide b), toField (bGameTurnsPlayed b), toField (bGameDurationSeconds b), toField (bGameEndedBy b), toField (bGameReplayUrl b), toField (bGameMatchId b), toField (bGameWinnerId b)]

data TournamentPrizePrizeTypeType
  = TournamentPrizePrizeTypeType_Currency
  | TournamentPrizePrizeTypeType_Cards
  | TournamentPrizePrizeTypeType_BoosterPacks
  | TournamentPrizePrizeTypeType_Trophy
  | TournamentPrizePrizeTypeType_SeasonPoints
  | TournamentPrizePrizeTypeType_Mixed
  deriving (Show, Eq, Generic)

instance ToJSON TournamentPrizePrizeTypeType where
  toJSON v = case v of
    TournamentPrizePrizeTypeType_Currency -> toJSON ("Currency" :: Text)
    TournamentPrizePrizeTypeType_Cards -> toJSON ("Cards" :: Text)
    TournamentPrizePrizeTypeType_BoosterPacks -> toJSON ("BoosterPacks" :: Text)
    TournamentPrizePrizeTypeType_Trophy -> toJSON ("Trophy" :: Text)
    TournamentPrizePrizeTypeType_SeasonPoints -> toJSON ("SeasonPoints" :: Text)
    TournamentPrizePrizeTypeType_Mixed -> toJSON ("Mixed" :: Text)
instance FromJSON TournamentPrizePrizeTypeType where
  parseJSON = withText "TournamentPrizePrizeTypeType" $ \txt ->
    if txt == "Currency" then pure TournamentPrizePrizeTypeType_Currency
    else if txt == "Cards" then pure TournamentPrizePrizeTypeType_Cards
    else if txt == "BoosterPacks" then pure TournamentPrizePrizeTypeType_BoosterPacks
    else if txt == "Trophy" then pure TournamentPrizePrizeTypeType_Trophy
    else if txt == "SeasonPoints" then pure TournamentPrizePrizeTypeType_SeasonPoints
    else if txt == "Mixed" then pure TournamentPrizePrizeTypeType_Mixed
    else fail ("Unknown TournamentPrizePrizeTypeType: " ++ show txt)

instance ToField TournamentPrizePrizeTypeType where
  toField TournamentPrizePrizeTypeType_Currency = toField ("Currency" :: Text)
  toField TournamentPrizePrizeTypeType_Cards = toField ("Cards" :: Text)
  toField TournamentPrizePrizeTypeType_BoosterPacks = toField ("BoosterPacks" :: Text)
  toField TournamentPrizePrizeTypeType_Trophy = toField ("Trophy" :: Text)
  toField TournamentPrizePrizeTypeType_SeasonPoints = toField ("SeasonPoints" :: Text)
  toField TournamentPrizePrizeTypeType_Mixed = toField ("Mixed" :: Text)

instance FromField TournamentPrizePrizeTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Currency" then return TournamentPrizePrizeTypeType_Currency
    else if txt == "Cards" then return TournamentPrizePrizeTypeType_Cards
    else if txt == "BoosterPacks" then return TournamentPrizePrizeTypeType_BoosterPacks
    else if txt == "Trophy" then return TournamentPrizePrizeTypeType_Trophy
    else if txt == "SeasonPoints" then return TournamentPrizePrizeTypeType_SeasonPoints
    else if txt == "Mixed" then return TournamentPrizePrizeTypeType_Mixed
    else returnError ConversionFailed f ("Unknown TournamentPrizePrizeTypeType: " ++ show txt)

_tournamentPrizeOpts :: Options
_tournamentPrizeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 15 }

data TournamentPrize = TournamentPrize
  { tournamentPrizeId :: Int
  , tournamentPrizePlacementFrom :: Int
  , tournamentPrizePlacementTo :: Int
  , tournamentPrizePrizeType :: TournamentPrizePrizeTypeType
  , tournamentPrizeAmount :: Text
  , tournamentPrizeDescription :: Maybe Text
  , tournamentPrizePacksCount :: Maybe Int
  , tournamentPrizeSeasonPoints :: Int
  , tournamentPrizeTournamentId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TournamentPrize where
  toJSON = genericToJSON _tournamentPrizeOpts
instance FromJSON TournamentPrize where
  parseJSON = genericParseJSON _tournamentPrizeOpts

instance FromRow TournamentPrize where
  fromRow = TournamentPrize <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTournamentPrizeOpts :: Options
_newTournamentPrizeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data NewTournamentPrize = NewTournamentPrize
  { bTournamentPrizePlacementFrom :: Int
  , bTournamentPrizePlacementTo :: Int
  , bTournamentPrizePrizeType :: TournamentPrizePrizeTypeType
  , bTournamentPrizeAmount :: Text
  , bTournamentPrizeDescription :: Maybe Text
  , bTournamentPrizePacksCount :: Maybe Int
  , bTournamentPrizeSeasonPoints :: Int
  , bTournamentPrizeTournamentId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTournamentPrize where
  toJSON = genericToJSON _newTournamentPrizeOpts
instance FromJSON NewTournamentPrize where
  parseJSON = genericParseJSON _newTournamentPrizeOpts

instance ToRow NewTournamentPrize where
  toRow b = [toField (bTournamentPrizePlacementFrom b), toField (bTournamentPrizePlacementTo b), toField (bTournamentPrizePrizeType b), toField (bTournamentPrizeAmount b), toField (bTournamentPrizeDescription b), toField (bTournamentPrizePacksCount b), toField (bTournamentPrizeSeasonPoints b), toField (bTournamentPrizeTournamentId b)]

_awardedPrizeOpts :: Options
_awardedPrizeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 12 }

data AwardedPrize = AwardedPrize
  { awardedPrizeId :: Int
  , awardedPrizeFinalPlacement :: Int
  , awardedPrizeAwardedAt :: Text
  , awardedPrizeClaimed :: Bool
  , awardedPrizeClaimedAt :: Maybe Text
  , awardedPrizePrizeId :: Maybe Int
  , awardedPrizePlayerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON AwardedPrize where
  toJSON = genericToJSON _awardedPrizeOpts
instance FromJSON AwardedPrize where
  parseJSON = genericParseJSON _awardedPrizeOpts

instance FromRow AwardedPrize where
  fromRow = AwardedPrize <$> field <*> field <*> field <*> field <*> field <*> field <*> field

_newAwardedPrizeOpts :: Options
_newAwardedPrizeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 13 }

data NewAwardedPrize = NewAwardedPrize
  { bAwardedPrizeFinalPlacement :: Int
  , bAwardedPrizeAwardedAt :: Text
  , bAwardedPrizeClaimed :: Bool
  , bAwardedPrizeClaimedAt :: Maybe Text
  , bAwardedPrizePrizeId :: Maybe Int
  , bAwardedPrizePlayerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewAwardedPrize where
  toJSON = genericToJSON _newAwardedPrizeOpts
instance FromJSON NewAwardedPrize where
  parseJSON = genericParseJSON _newAwardedPrizeOpts

instance ToRow NewAwardedPrize where
  toRow b = [toField (bAwardedPrizeFinalPlacement b), toField (bAwardedPrizeAwardedAt b), toField (bAwardedPrizeClaimed b), toField (bAwardedPrizeClaimedAt b), toField (bAwardedPrizePrizeId b), toField (bAwardedPrizePlayerId b)]

