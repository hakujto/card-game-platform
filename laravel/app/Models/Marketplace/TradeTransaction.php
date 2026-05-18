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
        return $this->belongsTo(TradeListing::class, 'listing_id');
    }

    public function buyer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'buyer_id');
    }

    public function seller(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'seller_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->platform_fee === null || ($this->final_price !== null && (float)$this->platform_fee <= (float)$this->final_price)))) {
            $errors['fee_not_exceed_price'] = 'Platform fee cannot exceed the final price';
        }
        if (!(($this->platform_fee === null || (float)$this->platform_fee >= (float)0))) {
            $errors['fee_not_negative'] = 'Platform fee must not be negative';
        }
        if (!(($this->final_price === null || (float)$this->final_price > (float)0))) {
            $errors['final_price_positive'] = 'Transaction final price must be greater than zero';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->status === 'Completed' && $this->completed_at === null) {
            throw new \RuntimeException('Completed transaction must have a completed_at timestamp');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function refund(): void
    {
        throw new \RuntimeException('refund not implemented');
    }

    public function openDispute($reason): void
    {
        throw new \RuntimeException('open_dispute not implemented');
    }

    public function sellerNet(): string
    {
        throw new \RuntimeException('seller_net not implemented');
    }

}
