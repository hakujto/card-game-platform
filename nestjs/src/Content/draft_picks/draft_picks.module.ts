import { Module } from '@nestjs/common';
import { DraftPickController } from './draft_picks.controller';
import { DraftPickService } from './draft_pick.service';

@Module({
  controllers: [DraftPickController],
  providers: [DraftPickService],
})
export class DraftPickModule {}
