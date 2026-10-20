import { Module } from '@nestjs/common';
import { TournamentJudgeController } from './tournament_judges.controller';
import { TournamentJudgeService } from './tournament_judge.service';

@Module({
  controllers: [TournamentJudgeController],
  providers: [TournamentJudgeService],
})
export class TournamentJudgeModule {}
