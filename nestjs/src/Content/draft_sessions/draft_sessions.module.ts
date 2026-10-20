import { Module } from '@nestjs/common';
import { DraftSessionController } from './draft_sessions.controller';
import { DraftSessionService } from './draft_session.service';

@Module({
  controllers: [DraftSessionController],
  providers: [DraftSessionService],
})
export class DraftSessionModule {}
