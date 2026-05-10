{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.StreamService where

import CardsProject.Content.Types

-- Domain service stub for Stream
validateStream :: NewStream -> Either String NewStream
validateStream body = Right body

