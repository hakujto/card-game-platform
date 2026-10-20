import { Module } from '@nestjs/common';
import { CardSetController } from './card_sets.controller';
import { CardSetService } from './card_set.service';

@Module({
  controllers: [CardSetController],
  providers: [CardSetService],
})
export class CardSetModule {}
