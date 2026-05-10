<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Coupon extends Model
{
    protected $table = 'coupons';

    protected $fillable = ['code', 'discount_type', 'discount_value', 'min_order_value', 'max_uses', 'uses_count', 'valid_from', 'valid_until', 'is_active'];

    protected $casts = [
        'discount_value' => 'decimal:2',
        'min_order_value' => 'decimal:2',
        'valid_from' => 'datetime',
        'valid_until' => 'datetime',
        'is_active' => 'boolean',
    ];

    const DISCOUNT_TYPE_VALUES = ['Percent', 'Fixed'];

}
