{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerService where

import CardsProject.Players.Types

-- Domain service stub for Player
validatePlayer :: NewPlayer -> Either String NewPlayer
validatePlayer body = Right body

