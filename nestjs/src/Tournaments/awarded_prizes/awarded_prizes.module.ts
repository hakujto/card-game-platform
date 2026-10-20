import { Module } from '@nestjs/common';
import { AwardedPrizeController } from './awarded_prizes.controller';
import { AwardedPrizeService } from './awarded_prize.service';

@Module({
  controllers: [AwardedPrizeController],
  providers: [AwardedPrizeService],
})
export class AwardedPrizeModule {}
