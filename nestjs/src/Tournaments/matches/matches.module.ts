import { Module } from '@nestjs/common';
import { MatchController } from './matches.controller';
import { MatchService } from './match.service';

@Module({
  controllers: [MatchController],
  providers: [MatchService],
})
export class MatchModule {}
