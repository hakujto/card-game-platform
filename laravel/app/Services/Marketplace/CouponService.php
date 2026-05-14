<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\Coupon;

class CouponService
{
    public function create(array $data): Coupon
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Coupon $coupon, array $data): Coupon
    {
        throw new \LogicException('Not implemented');
    }
    public function redeem(int $id): void
    {
        $coupon = Coupon::findOrFail($id);
        $coupon->redeem();
        $coupon->save();
    }

    public function deactivate(int $id): void
    {
        $coupon = Coupon::findOrFail($id);
        $coupon->deactivate();
        $coupon->save();
    }
}
