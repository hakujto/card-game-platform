import { Module } from '@nestjs/common';
import { DeckController } from './decks.controller';
import { DeckService } from './deck.service';

@Module({
  controllers: [DeckController],
  providers: [DeckService],
})
export class DeckModule {}
