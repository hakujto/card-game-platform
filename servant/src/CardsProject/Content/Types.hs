{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.Types where

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

data DraftSessionStatusType
  = DraftSessionStatusType_WaitingForPlayers
  | DraftSessionStatusType_Drafting
  | DraftSessionStatusType_Completed
  | DraftSessionStatusType_Abandoned
  deriving (Show, Eq, Generic)

instance ToJSON DraftSessionStatusType where
  toJSON v = case v of
    DraftSessionStatusType_WaitingForPlayers -> toJSON ("WaitingForPlayers" :: Text)
    DraftSessionStatusType_Drafting -> toJSON ("Drafting" :: Text)
    DraftSessionStatusType_Completed -> toJSON ("Completed" :: Text)
    DraftSessionStatusType_Abandoned -> toJSON ("Abandoned" :: Text)
instance FromJSON DraftSessionStatusType where
  parseJSON = withText "DraftSessionStatusType" $ \txt ->
    if txt == "WaitingForPlayers" then pure DraftSessionStatusType_WaitingForPlayers
    else if txt == "Drafting" then pure DraftSessionStatusType_Drafting
    else if txt == "Completed" then pure DraftSessionStatusType_Completed
    else if txt == "Abandoned" then pure DraftSessionStatusType_Abandoned
    else fail ("Unknown DraftSessionStatusType: " ++ show txt)

instance ToField DraftSessionStatusType where
  toField DraftSessionStatusType_WaitingForPlayers = toField ("WaitingForPlayers" :: Text)
  toField DraftSessionStatusType_Drafting = toField ("Drafting" :: Text)
  toField DraftSessionStatusType_Completed = toField ("Completed" :: Text)
  toField DraftSessionStatusType_Abandoned = toField ("Abandoned" :: Text)

instance FromField DraftSessionStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "WaitingForPlayers" then return DraftSessionStatusType_WaitingForPlayers
    else if txt == "Drafting" then return DraftSessionStatusType_Drafting
    else if txt == "Completed" then return DraftSessionStatusType_Completed
    else if txt == "Abandoned" then return DraftSessionStatusType_Abandoned
    else returnError ConversionFailed f ("Unknown DraftSessionStatusType: " ++ show txt)

data DraftSessionDraftTypeType
  = DraftSessionDraftTypeType_Booster
  | DraftSessionDraftTypeType_Cube
  | DraftSessionDraftTypeType_Rochester
  deriving (Show, Eq, Generic)

instance ToJSON DraftSessionDraftTypeType where
  toJSON v = case v of
    DraftSessionDraftTypeType_Booster -> toJSON ("Booster" :: Text)
    DraftSessionDraftTypeType_Cube -> toJSON ("Cube" :: Text)
    DraftSessionDraftTypeType_Rochester -> toJSON ("Rochester" :: Text)
instance FromJSON DraftSessionDraftTypeType where
  parseJSON = withText "DraftSessionDraftTypeType" $ \txt ->
    if txt == "Booster" then pure DraftSessionDraftTypeType_Booster
    else if txt == "Cube" then pure DraftSessionDraftTypeType_Cube
    else if txt == "Rochester" then pure DraftSessionDraftTypeType_Rochester
    else fail ("Unknown DraftSessionDraftTypeType: " ++ show txt)

instance ToField DraftSessionDraftTypeType where
  toField DraftSessionDraftTypeType_Booster = toField ("Booster" :: Text)
  toField DraftSessionDraftTypeType_Cube = toField ("Cube" :: Text)
  toField DraftSessionDraftTypeType_Rochester = toField ("Rochester" :: Text)

instance FromField DraftSessionDraftTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Booster" then return DraftSessionDraftTypeType_Booster
    else if txt == "Cube" then return DraftSessionDraftTypeType_Cube
    else if txt == "Rochester" then return DraftSessionDraftTypeType_Rochester
    else returnError ConversionFailed f ("Unknown DraftSessionDraftTypeType: " ++ show txt)

_draftSessionOpts :: Options
_draftSessionOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 12 }

data DraftSession = DraftSession
  { draftSessionId :: Int
  , draftSessionStatus :: DraftSessionStatusType
  , draftSessionDraftType :: DraftSessionDraftTypeType
  , draftSessionSeats :: Int
  , draftSessionCreatedAt :: Text
  , draftSessionCompletedAt :: Maybe Text
  , draftSessionCardSetId :: Maybe Int
  , draftSessionParticipantsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON DraftSession where
  toJSON = genericToJSON _draftSessionOpts
instance FromJSON DraftSession where
  parseJSON = genericParseJSON _draftSessionOpts

instance FromRow DraftSession where
  fromRow = DraftSession <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newDraftSessionOpts :: Options
_newDraftSessionOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 13 }

data NewDraftSession = NewDraftSession
  { bDraftSessionStatus :: DraftSessionStatusType
  , bDraftSessionDraftType :: DraftSessionDraftTypeType
  , bDraftSessionSeats :: Int
  , bDraftSessionCreatedAt :: Text
  , bDraftSessionCompletedAt :: Maybe Text
  , bDraftSessionCardSetId :: Maybe Int
  , bDraftSessionParticipantsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDraftSession where
  toJSON = genericToJSON _newDraftSessionOpts
instance FromJSON NewDraftSession where
  parseJSON = genericParseJSON _newDraftSessionOpts

instance ToRow NewDraftSession where
  toRow b = [toField (bDraftSessionStatus b), toField (bDraftSessionDraftType b), toField (bDraftSessionSeats b), toField (bDraftSessionCreatedAt b), toField (bDraftSessionCompletedAt b), toField (bDraftSessionCardSetId b), toField (bDraftSessionParticipantsId b)]

_draftParticipantOpts :: Options
_draftParticipantOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data DraftParticipant = DraftParticipant
  { draftParticipantId :: Int
  , draftParticipantSeatNumber :: Int
  , draftParticipantJoinedAt :: Text
  , draftParticipantSessionId :: Maybe Int
  , draftParticipantPlayerId :: Maybe Int
  , draftParticipantDraftedCardsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON DraftParticipant where
  toJSON = genericToJSON _draftParticipantOpts
instance FromJSON DraftParticipant where
  parseJSON = genericParseJSON _draftParticipantOpts

instance FromRow DraftParticipant where
  fromRow = DraftParticipant <$> field <*> field <*> field <*> field <*> field <*> field

_newDraftParticipantOpts :: Options
_newDraftParticipantOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data NewDraftParticipant = NewDraftParticipant
  { bDraftParticipantSeatNumber :: Int
  , bDraftParticipantJoinedAt :: Text
  , bDraftParticipantSessionId :: Maybe Int
  , bDraftParticipantPlayerId :: Maybe Int
  , bDraftParticipantDraftedCardsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDraftParticipant where
  toJSON = genericToJSON _newDraftParticipantOpts
instance FromJSON NewDraftParticipant where
  parseJSON = genericParseJSON _newDraftParticipantOpts

instance ToRow NewDraftParticipant where
  toRow b = [toField (bDraftParticipantSeatNumber b), toField (bDraftParticipantJoinedAt b), toField (bDraftParticipantSessionId b), toField (bDraftParticipantPlayerId b), toField (bDraftParticipantDraftedCardsId b)]

_draftPickOpts :: Options
_draftPickOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 9 }

data DraftPick = DraftPick
  { draftPickId :: Int
  , draftPickPickNumber :: Int
  , draftPickPackNumber :: Int
  , draftPickPickedAt :: Text
  , draftPickParticipantId :: Maybe Int
  , draftPickCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON DraftPick where
  toJSON = genericToJSON _draftPickOpts
instance FromJSON DraftPick where
  parseJSON = genericParseJSON _draftPickOpts

instance FromRow DraftPick where
  fromRow = DraftPick <$> field <*> field <*> field <*> field <*> field <*> field

_newDraftPickOpts :: Options
_newDraftPickOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 10 }

data NewDraftPick = NewDraftPick
  { bDraftPickPickNumber :: Int
  , bDraftPickPackNumber :: Int
  , bDraftPickPickedAt :: Text
  , bDraftPickParticipantId :: Maybe Int
  , bDraftPickCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewDraftPick where
  toJSON = genericToJSON _newDraftPickOpts
instance FromJSON NewDraftPick where
  parseJSON = genericParseJSON _newDraftPickOpts

instance ToRow NewDraftPick where
  toRow b = [toField (bDraftPickPickNumber b), toField (bDraftPickPackNumber b), toField (bDraftPickPickedAt b), toField (bDraftPickParticipantId b), toField (bDraftPickCardId b)]

data ArticleStatusType
  = ArticleStatusType_Draft
  | ArticleStatusType_Published
  | ArticleStatusType_Archived
  deriving (Show, Eq, Generic)

instance ToJSON ArticleStatusType where
  toJSON v = case v of
    ArticleStatusType_Draft -> toJSON ("Draft" :: Text)
    ArticleStatusType_Published -> toJSON ("Published" :: Text)
    ArticleStatusType_Archived -> toJSON ("Archived" :: Text)
instance FromJSON ArticleStatusType where
  parseJSON = withText "ArticleStatusType" $ \txt ->
    if txt == "Draft" then pure ArticleStatusType_Draft
    else if txt == "Published" then pure ArticleStatusType_Published
    else if txt == "Archived" then pure ArticleStatusType_Archived
    else fail ("Unknown ArticleStatusType: " ++ show txt)

instance ToField ArticleStatusType where
  toField ArticleStatusType_Draft = toField ("Draft" :: Text)
  toField ArticleStatusType_Published = toField ("Published" :: Text)
  toField ArticleStatusType_Archived = toField ("Archived" :: Text)

instance FromField ArticleStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Draft" then return ArticleStatusType_Draft
    else if txt == "Published" then return ArticleStatusType_Published
    else if txt == "Archived" then return ArticleStatusType_Archived
    else returnError ConversionFailed f ("Unknown ArticleStatusType: " ++ show txt)

data ArticleArticleTypeType
  = ArticleArticleTypeType_Guide
  | ArticleArticleTypeType_Tierlist
  | ArticleArticleTypeType_Matchup
  | ArticleArticleTypeType_News
  | ArticleArticleTypeType_Spotlight
  | ArticleArticleTypeType_Decklist
  deriving (Show, Eq, Generic)

instance ToJSON ArticleArticleTypeType where
  toJSON v = case v of
    ArticleArticleTypeType_Guide -> toJSON ("Guide" :: Text)
    ArticleArticleTypeType_Tierlist -> toJSON ("Tierlist" :: Text)
    ArticleArticleTypeType_Matchup -> toJSON ("Matchup" :: Text)
    ArticleArticleTypeType_News -> toJSON ("News" :: Text)
    ArticleArticleTypeType_Spotlight -> toJSON ("Spotlight" :: Text)
    ArticleArticleTypeType_Decklist -> toJSON ("Decklist" :: Text)
instance FromJSON ArticleArticleTypeType where
  parseJSON = withText "ArticleArticleTypeType" $ \txt ->
    if txt == "Guide" then pure ArticleArticleTypeType_Guide
    else if txt == "Tierlist" then pure ArticleArticleTypeType_Tierlist
    else if txt == "Matchup" then pure ArticleArticleTypeType_Matchup
    else if txt == "News" then pure ArticleArticleTypeType_News
    else if txt == "Spotlight" then pure ArticleArticleTypeType_Spotlight
    else if txt == "Decklist" then pure ArticleArticleTypeType_Decklist
    else fail ("Unknown ArticleArticleTypeType: " ++ show txt)

instance ToField ArticleArticleTypeType where
  toField ArticleArticleTypeType_Guide = toField ("Guide" :: Text)
  toField ArticleArticleTypeType_Tierlist = toField ("Tierlist" :: Text)
  toField ArticleArticleTypeType_Matchup = toField ("Matchup" :: Text)
  toField ArticleArticleTypeType_News = toField ("News" :: Text)
  toField ArticleArticleTypeType_Spotlight = toField ("Spotlight" :: Text)
  toField ArticleArticleTypeType_Decklist = toField ("Decklist" :: Text)

instance FromField ArticleArticleTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Guide" then return ArticleArticleTypeType_Guide
    else if txt == "Tierlist" then return ArticleArticleTypeType_Tierlist
    else if txt == "Matchup" then return ArticleArticleTypeType_Matchup
    else if txt == "News" then return ArticleArticleTypeType_News
    else if txt == "Spotlight" then return ArticleArticleTypeType_Spotlight
    else if txt == "Decklist" then return ArticleArticleTypeType_Decklist
    else returnError ConversionFailed f ("Unknown ArticleArticleTypeType: " ++ show txt)

_articleOpts :: Options
_articleOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data Article = Article
  { articleId :: Int
  , articleTitle :: Text
  , articleSlug :: Text
  , articleBody :: Text
  , articleExcerpt :: Maybe Text
  , articleCoverImageUrl :: Maybe Text
  , articleStatus :: ArticleStatusType
  , articleArticleType :: ArticleArticleTypeType
  , articleViewCount :: Int
  , articlePublishedAt :: Maybe Text
  , articleCreatedAt :: Text
  , articleUpdatedAt :: Text
  , articleAuthorId :: Maybe Int
  , articleFeaturedDeckId :: Maybe Int
  , articleCommentsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Article where
  toJSON = genericToJSON _articleOpts
instance FromJSON Article where
  parseJSON = genericParseJSON _articleOpts

instance FromRow Article where
  fromRow = Article <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newArticleOpts :: Options
_newArticleOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 8 }

data NewArticle = NewArticle
  { bArticleTitle :: Text
  , bArticleSlug :: Text
  , bArticleBody :: Text
  , bArticleExcerpt :: Maybe Text
  , bArticleCoverImageUrl :: Maybe Text
  , bArticleStatus :: ArticleStatusType
  , bArticleArticleType :: ArticleArticleTypeType
  , bArticleViewCount :: Int
  , bArticlePublishedAt :: Maybe Text
  , bArticleCreatedAt :: Text
  , bArticleUpdatedAt :: Text
  , bArticleAuthorId :: Maybe Int
  , bArticleFeaturedDeckId :: Maybe Int
  , bArticleCommentsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewArticle where
  toJSON = genericToJSON _newArticleOpts
instance FromJSON NewArticle where
  parseJSON = genericParseJSON _newArticleOpts

instance ToRow NewArticle where
  toRow b = [toField (bArticleTitle b), toField (bArticleSlug b), toField (bArticleBody b), toField (bArticleExcerpt b), toField (bArticleCoverImageUrl b), toField (bArticleStatus b), toField (bArticleArticleType b), toField (bArticleViewCount b), toField (bArticlePublishedAt b), toField (bArticleCreatedAt b), toField (bArticleUpdatedAt b), toField (bArticleAuthorId b), toField (bArticleFeaturedDeckId b), toField (bArticleCommentsId b)]

_articleTagOpts :: Options
_articleTagOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 10 }

data ArticleTag = ArticleTag
  { articleTagId :: Int
  , articleTagName :: Text
  , articleTagSlug :: Text
  } deriving (Show, Generic)

instance ToJSON ArticleTag where
  toJSON = genericToJSON _articleTagOpts
instance FromJSON ArticleTag where
  parseJSON = genericParseJSON _articleTagOpts

instance FromRow ArticleTag where
  fromRow = ArticleTag <$> field <*> field <*> field

_newArticleTagOpts :: Options
_newArticleTagOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 11 }

data NewArticleTag = NewArticleTag
  { bArticleTagName :: Text
  , bArticleTagSlug :: Text
  } deriving (Show, Generic)

instance ToJSON NewArticleTag where
  toJSON = genericToJSON _newArticleTagOpts
instance FromJSON NewArticleTag where
  parseJSON = genericParseJSON _newArticleTagOpts

instance ToRow NewArticleTag where
  toRow b = [toField (bArticleTagName b), toField (bArticleTagSlug b)]

_articleTagAssignmentOpts :: Options
_articleTagAssignmentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 20 }

data ArticleTagAssignment = ArticleTagAssignment
  { articleTagAssignmentId :: Int
  , articleTagAssignmentArticleId :: Maybe Int
  , articleTagAssignmentTagId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON ArticleTagAssignment where
  toJSON = genericToJSON _articleTagAssignmentOpts
instance FromJSON ArticleTagAssignment where
  parseJSON = genericParseJSON _articleTagAssignmentOpts

instance FromRow ArticleTagAssignment where
  fromRow = ArticleTagAssignment <$> field <*> field <*> field

_newArticleTagAssignmentOpts :: Options
_newArticleTagAssignmentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 21 }

data NewArticleTagAssignment = NewArticleTagAssignment
  { bArticleTagAssignmentArticleId :: Maybe Int
  , bArticleTagAssignmentTagId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewArticleTagAssignment where
  toJSON = genericToJSON _newArticleTagAssignmentOpts
instance FromJSON NewArticleTagAssignment where
  parseJSON = genericParseJSON _newArticleTagAssignmentOpts

instance ToRow NewArticleTagAssignment where
  toRow b = [toField (bArticleTagAssignmentArticleId b), toField (bArticleTagAssignmentTagId b)]

_articleCommentOpts :: Options
_articleCommentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 14 }

data ArticleComment = ArticleComment
  { articleCommentId :: Int
  , articleCommentBody :: Text
  , articleCommentIsHidden :: Bool
  , articleCommentCreatedAt :: Text
  , articleCommentArticleId :: Maybe Int
  , articleCommentAuthorId :: Maybe Int
  , articleCommentParentCommentId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON ArticleComment where
  toJSON = genericToJSON _articleCommentOpts
instance FromJSON ArticleComment where
  parseJSON = genericParseJSON _articleCommentOpts

instance FromRow ArticleComment where
  fromRow = ArticleComment <$> field <*> field <*> field <*> field <*> field <*> field <*> field

_newArticleCommentOpts :: Options
_newArticleCommentOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 15 }

data NewArticleComment = NewArticleComment
  { bArticleCommentBody :: Text
  , bArticleCommentIsHidden :: Bool
  , bArticleCommentCreatedAt :: Text
  , bArticleCommentArticleId :: Maybe Int
  , bArticleCommentAuthorId :: Maybe Int
  , bArticleCommentParentCommentId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewArticleComment where
  toJSON = genericToJSON _newArticleCommentOpts
instance FromJSON NewArticleComment where
  parseJSON = genericParseJSON _newArticleCommentOpts

instance ToRow NewArticleComment where
  toRow b = [toField (bArticleCommentBody b), toField (bArticleCommentIsHidden b), toField (bArticleCommentCreatedAt b), toField (bArticleCommentArticleId b), toField (bArticleCommentAuthorId b), toField (bArticleCommentParentCommentId b)]

data StreamPlatformType
  = StreamPlatformType_Twitch
  | StreamPlatformType_YouTube
  | StreamPlatformType_KickStream
  | StreamPlatformType_Platform
  deriving (Show, Eq, Generic)

instance ToJSON StreamPlatformType where
  toJSON v = case v of
    StreamPlatformType_Twitch -> toJSON ("Twitch" :: Text)
    StreamPlatformType_YouTube -> toJSON ("YouTube" :: Text)
    StreamPlatformType_KickStream -> toJSON ("KickStream" :: Text)
    StreamPlatformType_Platform -> toJSON ("Platform" :: Text)
instance FromJSON StreamPlatformType where
  parseJSON = withText "StreamPlatformType" $ \txt ->
    if txt == "Twitch" then pure StreamPlatformType_Twitch
    else if txt == "YouTube" then pure StreamPlatformType_YouTube
    else if txt == "KickStream" then pure StreamPlatformType_KickStream
    else if txt == "Platform" then pure StreamPlatformType_Platform
    else fail ("Unknown StreamPlatformType: " ++ show txt)

instance ToField StreamPlatformType where
  toField StreamPlatformType_Twitch = toField ("Twitch" :: Text)
  toField StreamPlatformType_YouTube = toField ("YouTube" :: Text)
  toField StreamPlatformType_KickStream = toField ("KickStream" :: Text)
  toField StreamPlatformType_Platform = toField ("Platform" :: Text)

instance FromField StreamPlatformType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Twitch" then return StreamPlatformType_Twitch
    else if txt == "YouTube" then return StreamPlatformType_YouTube
    else if txt == "KickStream" then return StreamPlatformType_KickStream
    else if txt == "Platform" then return StreamPlatformType_Platform
    else returnError ConversionFailed f ("Unknown StreamPlatformType: " ++ show txt)

data StreamStatusType
  = StreamStatusType_Scheduled
  | StreamStatusType_Live
  | StreamStatusType_Ended
  deriving (Show, Eq, Generic)

instance ToJSON StreamStatusType where
  toJSON v = case v of
    StreamStatusType_Scheduled -> toJSON ("Scheduled" :: Text)
    StreamStatusType_Live -> toJSON ("Live" :: Text)
    StreamStatusType_Ended -> toJSON ("Ended" :: Text)
instance FromJSON StreamStatusType where
  parseJSON = withText "StreamStatusType" $ \txt ->
    if txt == "Scheduled" then pure StreamStatusType_Scheduled
    else if txt == "Live" then pure StreamStatusType_Live
    else if txt == "Ended" then pure StreamStatusType_Ended
    else fail ("Unknown StreamStatusType: " ++ show txt)

instance ToField StreamStatusType where
  toField StreamStatusType_Scheduled = toField ("Scheduled" :: Text)
  toField StreamStatusType_Live = toField ("Live" :: Text)
  toField StreamStatusType_Ended = toField ("Ended" :: Text)

instance FromField StreamStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Scheduled" then return StreamStatusType_Scheduled
    else if txt == "Live" then return StreamStatusType_Live
    else if txt == "Ended" then return StreamStatusType_Ended
    else returnError ConversionFailed f ("Unknown StreamStatusType: " ++ show txt)

_streamOpts :: Options
_streamOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 6 }

data Stream = Stream
  { streamId :: Int
  , streamTitle :: Text
  , streamStreamUrl :: Text
  , streamPlatform :: StreamPlatformType
  , streamStatus :: StreamStatusType
  , streamViewerCountPeak :: Int
  , streamScheduledStart :: Text
  , streamActualStart :: Maybe Text
  , streamEndedAt :: Maybe Text
  , streamVodUrl :: Maybe Text
  , streamTournamentId :: Maybe Int
  , streamStreamerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Stream where
  toJSON = genericToJSON _streamOpts
instance FromJSON Stream where
  parseJSON = genericParseJSON _streamOpts

instance FromRow Stream where
  fromRow = Stream <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newStreamOpts :: Options
_newStreamOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data NewStream = NewStream
  { bStreamTitle :: Text
  , bStreamStreamUrl :: Text
  , bStreamPlatform :: StreamPlatformType
  , bStreamStatus :: StreamStatusType
  , bStreamViewerCountPeak :: Int
  , bStreamScheduledStart :: Text
  , bStreamActualStart :: Maybe Text
  , bStreamEndedAt :: Maybe Text
  , bStreamVodUrl :: Maybe Text
  , bStreamTournamentId :: Maybe Int
  , bStreamStreamerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewStream where
  toJSON = genericToJSON _newStreamOpts
instance FromJSON NewStream where
  parseJSON = genericParseJSON _newStreamOpts

instance ToRow NewStream where
  toRow b = [toField (bStreamTitle b), toField (bStreamStreamUrl b), toField (bStreamPlatform b), toField (bStreamStatus b), toField (bStreamViewerCountPeak b), toField (bStreamScheduledStart b), toField (bStreamActualStart b), toField (bStreamEndedAt b), toField (bStreamVodUrl b), toField (bStreamTournamentId b), toField (bStreamStreamerId b)]

