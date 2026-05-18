<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;
use App\Models\Cards\Card;

class TradeListing extends Model
{
    protected $table = 'trade_listings';

    protected $fillable = ['listing_type', 'asking_price', 'auction_start_price', 'auction_current_bid', 'auction_end_time', 'foil', 'condition', 'quantity', 'status', 'description', 'expires_at', 'seller_id', 'card_id'];

    protected $casts = [
        'asking_price' => 'decimal:2',
        'auction_start_price' => 'decimal:2',
        'auction_current_bid' => 'decimal:2',
        'auction_end_time' => 'datetime',
        'foil' => 'boolean',
        'expires_at' => 'datetime',
    ];

    const LISTING_TYPE_VALUES = ['FixedPrice', 'Auction', 'TradeOffer'];
    const CONDITION_VALUES = ['Mint', 'NearMint', 'Excellent', 'Good', 'Played'];
    const STATUS_VALUES = ['Active', 'Sold', 'Expired', 'Cancelled', 'Pending'];

    public function seller(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'seller_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->quantity === null || ($this->quantity >= 1 && $this->quantity <= 9999)))) {
            $errors['quantity_positive'] = 'Listing quantity must be between 1 and 9999';
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
        if ($this->listing_type === 'FixedPrice' && $this->asking_price === null) {
            throw new \RuntimeException('Fixed price listing must have an asking price');
        }
        if ($this->listing_type === 'Auction' && !($this->auction_start_price !== null && $this->auction_end_time !== null)) {
            throw new \RuntimeException('Auction listing must have a start price and end time');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function close(): void
    {
        throw new \RuntimeException('close not implemented');
    }

    public function extend($days): void
    {
        throw new \RuntimeException('extend not implemented');
    }

    public function cancel(): void
    {
        throw new \RuntimeException('cancel not implemented');
    }

    public function isExpired(): bool
    {
        throw new \RuntimeException('is_expired not implemented');
    }

    public function finalizeAuction(): void
    {
        throw new \RuntimeException('finalize_auction not implemented');
    }

}
