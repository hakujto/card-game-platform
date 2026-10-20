import { Module } from '@nestjs/common';
import { SeasonController } from './seasons.controller';
import { SeasonService } from './season.service';

@Module({
  controllers: [SeasonController],
  providers: [SeasonService],
})
export class SeasonModule {}
