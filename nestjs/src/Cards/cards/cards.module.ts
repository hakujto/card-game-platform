import { Module } from '@nestjs/common';
import { CardController } from './cards.controller';
import { CardService } from './card.service';

@Module({
  controllers: [CardController],
  providers: [CardService],
})
export class CardModule {}
