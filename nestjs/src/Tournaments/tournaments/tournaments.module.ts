import { Module } from '@nestjs/common';
import { TournamentController } from './tournaments.controller';
import { TournamentService } from './tournament.service';

@Module({
  controllers: [TournamentController],
  providers: [TournamentService],
})
export class TournamentModule {}
