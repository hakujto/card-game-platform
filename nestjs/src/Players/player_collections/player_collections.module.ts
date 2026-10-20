import { Module } from '@nestjs/common';
import { PlayerCollectionController } from './player_collections.controller';
import { PlayerCollectionService } from './player_collection.service';

@Module({
  controllers: [PlayerCollectionController],
  providers: [PlayerCollectionService],
})
export class PlayerCollectionModule {}
