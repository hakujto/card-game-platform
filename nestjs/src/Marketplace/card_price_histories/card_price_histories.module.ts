import { Module } from '@nestjs/common';
import { CardPriceHistoryController } from './card_price_histories.controller';
import { CardPriceHistoryService } from './card_price_history.service';

@Module({
  controllers: [CardPriceHistoryController],
  providers: [CardPriceHistoryService],
})
export class CardPriceHistoryModule {}
