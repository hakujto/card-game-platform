{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.App (app, combinedAPI, combinedServer) where

import Servant hiding (Stream)
import Network.Wai (Application)
import Network.Wai.Middleware.Cors
import Data.ByteString (ByteString)
import Data.CaseInsensitive (mk)
import CardsProject.Cards.CardHandler (cardServer, CardAPI)
import CardsProject.Cards.CardSetHandler (cardSetServer, CardSetAPI)
import CardsProject.Cards.CardRulingHandler (cardRulingServer, CardRulingAPI)
import CardsProject.Cards.CardAbilityHandler (cardAbilityServer, CardAbilityAPI)
import CardsProject.Cards.DeckHandler (deckServer, DeckAPI)
import CardsProject.Cards.DeckCardHandler (deckCardServer, DeckCardAPI)
import CardsProject.Cards.DeckSideboardCardHandler (deckSideboardCardServer, DeckSideboardCardAPI)
import CardsProject.Cards.DeckTagHandler (deckTagServer, DeckTagAPI)
import CardsProject.Cards.DeckTagAssignmentHandler (deckTagAssignmentServer, DeckTagAssignmentAPI)
import CardsProject.Players.PlayerHandler (playerServer, PlayerAPI)
import CardsProject.Players.PlayerSeasonStatsHandler (playerSeasonStatsServer, PlayerSeasonStatsAPI)
import CardsProject.Players.PlayerCollectionHandler (playerCollectionServer, PlayerCollectionAPI)
import CardsProject.Players.FriendshipHandler (friendshipServer, FriendshipAPI)
import CardsProject.Players.AchievementHandler (achievementServer, AchievementAPI)
import CardsProject.Players.PlayerAchievementHandler (playerAchievementServer, PlayerAchievementAPI)
import CardsProject.Players.CraftingRecipeHandler (craftingRecipeServer, CraftingRecipeAPI)
import CardsProject.Players.CraftingIngredientHandler (craftingIngredientServer, CraftingIngredientAPI)
import CardsProject.Tournaments.SeasonHandler (seasonServer, SeasonAPI)
import CardsProject.Tournaments.TournamentHandler (tournamentServer, TournamentAPI)
import CardsProject.Tournaments.TournamentJudgeHandler (tournamentJudgeServer, TournamentJudgeAPI)
import CardsProject.Tournaments.TournamentRegistrationHandler (tournamentRegistrationServer, TournamentRegistrationAPI)
import CardsProject.Tournaments.TournamentRoundHandler (tournamentRoundServer, TournamentRoundAPI)
import CardsProject.Tournaments.MatchHandler (matchServer, MatchAPI)
import CardsProject.Tournaments.GameHandler (gameServer, GameAPI)
import CardsProject.Tournaments.TournamentPrizeHandler (tournamentPrizeServer, TournamentPrizeAPI)
import CardsProject.Tournaments.AwardedPrizeHandler (awardedPrizeServer, AwardedPrizeAPI)
import CardsProject.Marketplace.ProductHandler (productServer, ProductAPI)
import CardsProject.Marketplace.OrderHandler (orderServer, OrderAPI)
import CardsProject.Marketplace.OrderItemHandler (orderItemServer, OrderItemAPI)
import CardsProject.Marketplace.CouponHandler (couponServer, CouponAPI)
import CardsProject.Marketplace.TradelistingHandler (tradelistingServer, TradelistingAPI)
import CardsProject.Marketplace.TradeBidHandler (tradeBidServer, TradeBidAPI)
import CardsProject.Marketplace.TradeTransactionHandler (tradeTransactionServer, TradeTransactionAPI)
import CardsProject.Marketplace.CardPriceHistoryHandler (cardPriceHistoryServer, CardPriceHistoryAPI)
import CardsProject.Marketplace.TradeDisputeHandler (tradeDisputeServer, TradeDisputeAPI)
import CardsProject.Content.DraftSessionHandler (draftSessionServer, DraftSessionAPI)
import CardsProject.Content.DraftParticipantHandler (draftParticipantServer, DraftParticipantAPI)
import CardsProject.Content.DraftPickHandler (draftPickServer, DraftPickAPI)
import CardsProject.Content.ArticleHandler (articleServer, ArticleAPI)
import CardsProject.Content.ArticleTagHandler (articleTagServer, ArticleTagAPI)
import CardsProject.Content.ArticleTagAssignmentHandler (articleTagAssignmentServer, ArticleTagAssignmentAPI)
import CardsProject.Content.ArticleCommentHandler (articleCommentServer, ArticleCommentAPI)
import CardsProject.Content.StreamHandler (streamServer, StreamAPI)

type CombinedAPI = CardAPI
  :<|> CardSetAPI
  :<|> CardRulingAPI
  :<|> CardAbilityAPI
  :<|> DeckAPI
  :<|> DeckCardAPI
  :<|> DeckSideboardCardAPI
  :<|> DeckTagAPI
  :<|> DeckTagAssignmentAPI
  :<|> PlayerAPI
  :<|> PlayerSeasonStatsAPI
  :<|> PlayerCollectionAPI
  :<|> FriendshipAPI
  :<|> AchievementAPI
  :<|> PlayerAchievementAPI
  :<|> CraftingRecipeAPI
  :<|> CraftingIngredientAPI
  :<|> SeasonAPI
  :<|> TournamentAPI
  :<|> TournamentJudgeAPI
  :<|> TournamentRegistrationAPI
  :<|> TournamentRoundAPI
  :<|> MatchAPI
  :<|> GameAPI
  :<|> TournamentPrizeAPI
  :<|> AwardedPrizeAPI
  :<|> ProductAPI
  :<|> OrderAPI
  :<|> OrderItemAPI
  :<|> CouponAPI
  :<|> TradelistingAPI
  :<|> TradeBidAPI
  :<|> TradeTransactionAPI
  :<|> CardPriceHistoryAPI
  :<|> TradeDisputeAPI
  :<|> DraftSessionAPI
  :<|> DraftParticipantAPI
  :<|> DraftPickAPI
  :<|> ArticleAPI
  :<|> ArticleTagAPI
  :<|> ArticleTagAssignmentAPI
  :<|> ArticleCommentAPI
  :<|> StreamAPI

combinedAPI :: Proxy CombinedAPI
combinedAPI = Proxy

combinedServer :: Server CombinedAPI
combinedServer = cardServer
  :<|> cardSetServer
  :<|> cardRulingServer
  :<|> cardAbilityServer
  :<|> deckServer
  :<|> deckCardServer
  :<|> deckSideboardCardServer
  :<|> deckTagServer
  :<|> deckTagAssignmentServer
  :<|> playerServer
  :<|> playerSeasonStatsServer
  :<|> playerCollectionServer
  :<|> friendshipServer
  :<|> achievementServer
  :<|> playerAchievementServer
  :<|> craftingRecipeServer
  :<|> craftingIngredientServer
  :<|> seasonServer
  :<|> tournamentServer
  :<|> tournamentJudgeServer
  :<|> tournamentRegistrationServer
  :<|> tournamentRoundServer
  :<|> matchServer
  :<|> gameServer
  :<|> tournamentPrizeServer
  :<|> awardedPrizeServer
  :<|> productServer
  :<|> orderServer
  :<|> orderItemServer
  :<|> couponServer
  :<|> tradelistingServer
  :<|> tradeBidServer
  :<|> tradeTransactionServer
  :<|> cardPriceHistoryServer
  :<|> tradeDisputeServer
  :<|> draftSessionServer
  :<|> draftParticipantServer
  :<|> draftPickServer
  :<|> articleServer
  :<|> articleTagServer
  :<|> articleTagAssignmentServer
  :<|> articleCommentServer
  :<|> streamServer

app :: Application
app = corsMiddleware $ serve combinedAPI combinedServer
  where
    corsPolicy = simpleCorsResourcePolicy
      { corsOrigins = Nothing
      , corsMethods = (["GET","POST","PUT","PATCH","DELETE","OPTIONS"] :: [ByteString])
      , corsRequestHeaders = map mk (["Content-Type","Accept"] :: [ByteString])
      }
    corsMiddleware = cors (const $ Just corsPolicy)

