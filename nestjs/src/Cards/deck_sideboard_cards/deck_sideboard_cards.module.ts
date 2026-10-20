import { Module } from '@nestjs/common';
import { DeckSideboardCardController } from './deck_sideboard_cards.controller';
import { DeckSideboardCardService } from './deck_sideboard_card.service';

@Module({
  controllers: [DeckSideboardCardController],
  providers: [DeckSideboardCardService],
})
export class DeckSideboardCardModule {}
