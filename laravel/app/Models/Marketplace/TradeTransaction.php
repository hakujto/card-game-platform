<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class TradeTransaction extends Model
{
    protected $table = 'trade_transactions';

    protected $fillable = ['final_price', 'platform_fee', 'status', 'completed_at', 'listing_id', 'buyer_id', 'seller_id'];

    protected $casts = [
        'final_price' => 'decimal:2',
        'platform_fee' => 'decimal:2',
        'completed_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Pending', 'Completed', 'Disputed', 'Refunded'];

    public function listing(): BelongsTo
    {
        return $this->belongsTo(Tradelisting::class, 'listing_id');
    }

    public function buyer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'buyer_id');
    }

    public function seller(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'seller_id');
    }

}
