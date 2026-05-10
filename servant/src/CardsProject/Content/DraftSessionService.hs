{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftSessionService where

import CardsProject.Content.Types

-- Domain service stub for DraftSession
validateDraftSession :: NewDraftSession -> Either String NewDraftSession
validateDraftSession body = Right body

