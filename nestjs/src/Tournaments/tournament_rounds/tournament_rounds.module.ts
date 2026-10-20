import { Module } from '@nestjs/common';
import { TournamentRoundController } from './tournament_rounds.controller';
import { TournamentRoundService } from './tournament_round.service';

@Module({
  controllers: [TournamentRoundController],
  providers: [TournamentRoundService],
})
export class TournamentRoundModule {}
