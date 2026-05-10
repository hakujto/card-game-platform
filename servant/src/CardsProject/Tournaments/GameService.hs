{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.GameService where

import CardsProject.Tournaments.Types

-- Domain service stub for Game
validateGame :: NewGame -> Either String NewGame
validateGame body = Right body

