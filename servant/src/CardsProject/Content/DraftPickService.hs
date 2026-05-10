{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftPickService where

import CardsProject.Content.Types

-- Domain service stub for DraftPick
validateDraftPick :: NewDraftPick -> Either String NewDraftPick
validateDraftPick body = Right body

