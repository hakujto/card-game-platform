import { Module } from '@nestjs/common';
import { PlayerAchievementController } from './player_achievements.controller';
import { PlayerAchievementService } from './player_achievement.service';

@Module({
  controllers: [PlayerAchievementController],
  providers: [PlayerAchievementService],
})
export class PlayerAchievementModule {}
