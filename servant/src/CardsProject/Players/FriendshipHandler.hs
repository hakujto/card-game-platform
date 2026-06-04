{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.FriendshipHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Players.FriendshipService as FriendshipSvc
import Control.Exception (catch, IOException)
import Data.Text (Text)

type FriendshipAPI
  =    "api" :> "friendships" :> Get '[JSON] [Friendship]
  :<|> "api" :> "friendships" :> ReqBody '[JSON] NewFriendship :> PostCreated '[JSON] Friendship
  :<|> "api" :> "friendships" :> Capture "id" Int :> Get '[JSON] Friendship
  :<|> "api" :> "friendships" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "friendships" :> Capture "id" Int :> "accept" :> PostNoContent
  :<|> "api" :> "friendships" :> Capture "id" Int :> "decline" :> PostNoContent
  :<|> "api" :> "friendships" :> Capture "id" Int :> "block" :> PostNoContent

friendshipServer :: Server FriendshipAPI
friendshipServer = listAll
  :<|> create
  :<|> getOne
  :<|> delete
  :<|> behaviorAccept
  :<|> behaviorDecline
  :<|> behaviorBlock
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, created_at, requester_id, receiver_id FROM friendships" :: IO [Friendship]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO friendships (status, created_at, requester_id, receiver_id) VALUES (?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, status, created_at, requester_id, receiver_id FROM friendships WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Friendship]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, created_at, requester_id, receiver_id FROM friendships WHERE id = ?" (Only eid) :: IO [Friendship]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM friendships WHERE id = ?" (Only eid)
      return NoContent

    behaviorAccept eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, created_at, requester_id, receiver_id FROM friendships WHERE id = ?" (Only eid) :: IO [Friendship]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> FriendshipSvc.accept eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDecline eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, created_at, requester_id, receiver_id FROM friendships WHERE id = ?" (Only eid) :: IO [Friendship]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> FriendshipSvc.decline eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorBlock eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, created_at, requester_id, receiver_id FROM friendships WHERE id = ?" (Only eid) :: IO [Friendship]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> FriendshipSvc.block eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

