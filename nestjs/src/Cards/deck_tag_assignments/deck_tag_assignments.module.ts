import { Module } from '@nestjs/common';
import { DeckTagAssignmentController } from './deck_tag_assignments.controller';

@Module({
  controllers: [DeckTagAssignmentController],
  providers: [],
})
export class DeckTagAssignmentModule {}
