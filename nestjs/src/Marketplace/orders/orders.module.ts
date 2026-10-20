import { Module } from '@nestjs/common';
import { OrderController } from './orders.controller';
import { OrderService } from './order.service';

@Module({
  controllers: [OrderController],
  providers: [OrderService],
})
export class OrderModule {}
