import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { CardModule } from './Cards/cards/cards.module';
import { CardSetModule } from './Cards/card_sets/card_sets.module';
import { CardRulingModule } from './Cards/card_rulings/card_rulings.module';
import { CardAbilityModule } from './Cards/card_abilities/card_abilities.module';
import { DeckModule } from './Cards/decks/decks.module';
import { DeckCardModule } from './Cards/deck_cards/deck_cards.module';
import { DeckSideboardCardModule } from './Cards/deck_sideboard_cards/deck_sideboard_cards.module';
import { DeckTagModule } from './Cards/deck_tags/deck_tags.module';
import { DeckTagAssignmentModule } from './Cards/deck_tag_assignments/deck_tag_assignments.module';
import { PlayerModule } from './Players/players/players.module';
import { PlayerSeasonStatsModule } from './Players/player_season_statses/player_season_statses.module';
import { PlayerCollectionModule } from './Players/player_collections/player_collections.module';
import { FriendshipModule } from './Players/friendships/friendships.module';
import { AchievementModule } from './Players/achievements/achievements.module';
import { PlayerAchievementModule } from './Players/player_achievements/player_achievements.module';
import { CraftingRecipeModule } from './Players/crafting_recipes/crafting_recipes.module';
import { CraftingIngredientModule } from './Players/crafting_ingredients/crafting_ingredients.module';
import { SeasonModule } from './Tournaments/seasons/seasons.module';
import { TournamentModule } from './Tournaments/tournaments/tournaments.module';
import { TournamentJudgeModule } from './Tournaments/tournament_judges/tournament_judges.module';
import { TournamentRegistrationModule } from './Tournaments/tournament_registrations/tournament_registrations.module';
import { TournamentRoundModule } from './Tournaments/tournament_rounds/tournament_rounds.module';
import { MatchModule } from './Tournaments/matches/matches.module';
import { GameModule } from './Tournaments/games/games.module';
import { TournamentPrizeModule } from './Tournaments/tournament_prizes/tournament_prizes.module';
import { AwardedPrizeModule } from './Tournaments/awarded_prizes/awarded_prizes.module';
import { ProductModule } from './Marketplace/products/products.module';
import { OrderModule } from './Marketplace/orders/orders.module';
import { OrderItemModule } from './Marketplace/order_items/order_items.module';
import { CouponModule } from './Marketplace/coupons/coupons.module';
import { TradeListingModule } from './Marketplace/trade_listings/trade_listings.module';
import { TradeBidModule } from './Marketplace/trade_bids/trade_bids.module';
import { TradeTransactionModule } from './Marketplace/trade_transactions/trade_transactions.module';
import { CardPriceHistoryModule } from './Marketplace/card_price_histories/card_price_histories.module';
import { TradeDisputeModule } from './Marketplace/trade_disputes/trade_disputes.module';
import { DraftSessionModule } from './Content/draft_sessions/draft_sessions.module';
import { DraftParticipantModule } from './Content/draft_participants/draft_participants.module';
import { DraftPickModule } from './Content/draft_picks/draft_picks.module';
import { ArticleModule } from './Content/articles/articles.module';
import { ArticleTagModule } from './Content/article_tags/article_tags.module';
import { ArticleTagAssignmentModule } from './Content/article_tag_assignments/article_tag_assignments.module';
import { ArticleCommentModule } from './Content/article_comments/article_comments.module';
import { StreamModule } from './Content/streams/streams.module';

@Module({
  imports: [
    PrismaModule,
    CardModule,
    CardSetModule,
    CardRulingModule,
    CardAbilityModule,
    DeckModule,
    DeckCardModule,
    DeckSideboardCardModule,
    DeckTagModule,
    DeckTagAssignmentModule,
    PlayerModule,
    PlayerSeasonStatsModule,
    PlayerCollectionModule,
    FriendshipModule,
    AchievementModule,
    PlayerAchievementModule,
    CraftingRecipeModule,
    CraftingIngredientModule,
    SeasonModule,
    TournamentModule,
    TournamentJudgeModule,
    TournamentRegistrationModule,
    TournamentRoundModule,
    MatchModule,
    GameModule,
    TournamentPrizeModule,
    AwardedPrizeModule,
    ProductModule,
    OrderModule,
    OrderItemModule,
    CouponModule,
    TradeListingModule,
    TradeBidModule,
    TradeTransactionModule,
    CardPriceHistoryModule,
    TradeDisputeModule,
    DraftSessionModule,
    DraftParticipantModule,
    DraftPickModule,
    ArticleModule,
    ArticleTagModule,
    ArticleTagAssignmentModule,
    ArticleCommentModule,
    StreamModule,
  ],
})
export class AppModule {}
