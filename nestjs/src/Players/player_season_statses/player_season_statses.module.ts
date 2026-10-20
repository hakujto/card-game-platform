import { Module } from '@nestjs/common';
import { PlayerSeasonStatsController } from './player_season_statses.controller';
import { PlayerSeasonStatsService } from './player_season_stats.service';

@Module({
  controllers: [PlayerSeasonStatsController],
  providers: [PlayerSeasonStatsService],
})
export class PlayerSeasonStatsModule {}
