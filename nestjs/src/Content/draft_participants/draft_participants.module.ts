import { Module } from '@nestjs/common';
import { DraftParticipantController } from './draft_participants.controller';
import { DraftParticipantService } from './draft_participant.service';

@Module({
  controllers: [DraftParticipantController],
  providers: [DraftParticipantService],
})
export class DraftParticipantModule {}
