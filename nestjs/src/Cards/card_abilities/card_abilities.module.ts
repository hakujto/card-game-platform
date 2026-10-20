import { Module } from '@nestjs/common';
import { CardAbilityController } from './card_abilities.controller';
import { CardAbilityService } from './card_ability.service';

@Module({
  controllers: [CardAbilityController],
  providers: [CardAbilityService],
})
export class CardAbilityModule {}
