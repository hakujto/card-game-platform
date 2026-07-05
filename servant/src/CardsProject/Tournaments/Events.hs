{-# LANGUAGE DeriveGeneric #-}
module CardsProject.Tournaments.Events where

import Data.Aeson (ToJSON, FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data TournamentCompleted = TournamentCompleted
  { tournamentId :: Int
  , seasonId :: Int
  , completedAt :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON TournamentCompleted
instance FromJSON TournamentCompleted

data PlayerRegistered = PlayerRegistered
  { tournamentId :: Int
  , playerId :: Int
  , registeredAt :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON PlayerRegistered
instance FromJSON PlayerRegistered

