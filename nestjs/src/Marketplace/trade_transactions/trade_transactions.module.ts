import { Module } from '@nestjs/common';
import { TradeTransactionController } from './trade_transactions.controller';
import { TradeTransactionService } from './trade_transaction.service';

@Module({
  controllers: [TradeTransactionController],
  providers: [TradeTransactionService],
})
export class TradeTransactionModule {}
