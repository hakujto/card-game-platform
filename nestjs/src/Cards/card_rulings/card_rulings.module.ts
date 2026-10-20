import { Module } from '@nestjs/common';
import { CardRulingController } from './card_rulings.controller';
import { CardRulingService } from './card_ruling.service';

@Module({
  controllers: [CardRulingController],
  providers: [CardRulingService],
})
export class CardRulingModule {}
