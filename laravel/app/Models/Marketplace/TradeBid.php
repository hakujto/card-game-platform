<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class TradeBid extends Model
{
    protected $table = 'trade_bids';

    protected $fillable = ['amount', 'placed_at', 'is_winning', 'listing_id', 'bidder_id'];

    protected $casts = [
        'amount' => 'decimal:2',
        'placed_at' => 'datetime',
        'is_winning' => 'boolean',
    ];

    public function listing(): BelongsTo
    {
        return $this->belongsTo(Tradelisting::class, 'listing_id');
    }

    public function bidder(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'bidder_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->amount === null || (float)$this->amount > (float)0))) {
            $errors['amount_positive'] = 'Bid amount must be greater than zero';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function outbidBy($new_amount): bool
    {
        throw new \RuntimeException('outbid_by not implemented');
    }

}
