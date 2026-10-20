import { Module } from '@nestjs/common';
import { TradeBidController } from './trade_bids.controller';
import { TradeBidService } from './trade_bid.service';

@Module({
  controllers: [TradeBidController],
  providers: [TradeBidService],
})
export class TradeBidModule {}
