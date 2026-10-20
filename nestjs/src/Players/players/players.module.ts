import { Module } from '@nestjs/common';
import { PlayerController } from './players.controller';
import { PlayerService } from './player.service';

@Module({
  controllers: [PlayerController],
  providers: [PlayerService],
})
export class PlayerModule {}
