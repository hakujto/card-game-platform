import { Module } from '@nestjs/common';
import { AchievementController } from './achievements.controller';
import { AchievementService } from './achievement.service';

@Module({
  controllers: [AchievementController],
  providers: [AchievementService],
})
export class AchievementModule {}
