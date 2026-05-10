<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class Order extends Model
{
    protected $table = 'orders';

    protected $fillable = ['status', 'total', 'discount_applied', 'currency', 'payment_method', 'payment_reference', 'shipping_address', 'tracking_number', 'paid_at', 'shipped_at', 'player_id', 'coupon_id'];

    protected $casts = [
        'total' => 'decimal:2',
        'discount_applied' => 'decimal:2',
        'paid_at' => 'datetime',
        'shipped_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Pending', 'Paid', 'Processing', 'Shipped', 'Completed', 'Cancelled', 'Refunded'];
    const PAYMENT_METHOD_VALUES = ['Card', 'PayPal', 'Crypto', 'PlatformCredits'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function coupon(): BelongsTo
    {
        return $this->belongsTo(Coupon::class, 'coupon_id');
    }

}
