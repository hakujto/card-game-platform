import { Module } from '@nestjs/common';
import { TradeListingController } from './trade_listings.controller';
import { TradeListingService } from './trade_listing.service';

@Module({
  controllers: [TradeListingController],
  providers: [TradeListingService],
})
export class TradeListingModule {}
