{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.FriendshipService where

import CardsProject.Players.Types

-- Domain service stub for Friendship
validateFriendship :: NewFriendship -> Either String NewFriendship
validateFriendship body = Right body

