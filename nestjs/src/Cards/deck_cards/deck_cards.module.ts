import { Module } from '@nestjs/common';
import { DeckCardController } from './deck_cards.controller';
import { DeckCardService } from './deck_card.service';

@Module({
  controllers: [DeckCardController],
  providers: [DeckCardService],
})
export class DeckCardModule {}
