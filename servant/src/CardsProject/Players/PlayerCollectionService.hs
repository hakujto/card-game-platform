{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerCollectionService where

import CardsProject.Players.Types

-- Domain service stub for PlayerCollection
validatePlayerCollection :: NewPlayerCollection -> Either String NewPlayerCollection
validatePlayerCollection body = Right body

