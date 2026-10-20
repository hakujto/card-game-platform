import { Module } from '@nestjs/common';
import { CouponController } from './coupons.controller';
import { CouponService } from './coupon.service';

@Module({
  controllers: [CouponController],
  providers: [CouponService],
})
export class CouponModule {}
