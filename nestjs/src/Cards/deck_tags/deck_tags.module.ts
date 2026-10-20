import { Module } from '@nestjs/common';
import { DeckTagController } from './deck_tags.controller';
import { DeckTagService } from './deck_tag.service';

@Module({
  controllers: [DeckTagController],
  providers: [DeckTagService],
})
export class DeckTagModule {}
