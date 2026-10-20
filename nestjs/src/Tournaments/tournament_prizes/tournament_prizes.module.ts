import { Module } from '@nestjs/common';
import { TournamentPrizeController } from './tournament_prizes.controller';
import { TournamentPrizeService } from './tournament_prize.service';

@Module({
  controllers: [TournamentPrizeController],
  providers: [TournamentPrizeService],
})
export class TournamentPrizeModule {}
