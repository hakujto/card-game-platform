{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftParticipantService where

import CardsProject.Content.Types

-- Domain service stub for DraftParticipant
validateDraftParticipant :: NewDraftParticipant -> Either String NewDraftParticipant
validateDraftParticipant body = Right body

