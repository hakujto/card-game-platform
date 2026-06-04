{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Content.DraftPickHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Content.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Content.DraftPickService as DraftPickSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)

type DraftPickAPI
  =    "api" :> "draft_picks" :> Get '[JSON] [DraftPick]
  :<|> "api" :> "draft_picks" :> Capture "id" Int :> Get '[JSON] DraftPick
  :<|> "api" :> "draft_picks" :> Capture "id" Int :> "first-pick" :> Get '[JSON] Bool

draftPickServer :: Server DraftPickAPI
draftPickServer = listAll
  :<|> getOne
  :<|> behaviorIsFirstPick
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks" :: IO [DraftPick]

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks WHERE id = ?" (Only eid) :: IO [DraftPick]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    behaviorIsFirstPick eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id FROM draft_picks WHERE id = ?" (Only eid) :: IO [DraftPick]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> DraftPickSvc.is_first_pick eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

