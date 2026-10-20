import { Module } from '@nestjs/common';
import { TradeDisputeController } from './trade_disputes.controller';
import { TradeDisputeService } from './trade_dispute.service';

@Module({
  controllers: [TradeDisputeController],
  providers: [TradeDisputeService],
})
export class TradeDisputeModule {}
