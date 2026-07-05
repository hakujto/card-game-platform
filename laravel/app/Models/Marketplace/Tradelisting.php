<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use App\Models\Players\Player;
use App\Models\Cards\Card;

class TradeListing extends Model
{
    protected $table = 'trade_listings';

    protected $fillable = ['public_id', 'status', 'listing_type', 'asking_price', 'auction_start_price', 'auction_current_bid', 'auction_end_time', 'foil', 'condition', 'quantity', 'description', 'expires_at', 'seller_id', 'card_id'];

    protected $casts = [
        'public_id' => 'string',
        'asking_price' => 'decimal:2',
        'auction_start_price' => 'decimal:2',
        'auction_current_bid' => 'decimal:2',
        'auction_end_time' => 'datetime',
        'foil' => 'boolean',
        'expires_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Active', 'Sold', 'Expired', 'Cancelled', 'Pending'];
    const LISTING_TYPE_VALUES = ['FixedPrice', 'Auction', 'TradeOffer'];
    const CONDITION_VALUES = ['Mint', 'NearMint', 'Excellent', 'Good', 'Played'];

    public function seller(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'seller_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    public function bids(): HasMany
    {
        return $this->hasMany(TradeBid::class, 'listing_id');
    }

    public function transaction(): HasOne
    {
        return $this->hasOne(TradeTransaction::class, 'listing_id');
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

    // ── Lifecycle state machine ──────────────────────────────────────
    const ALLOWED_TRANSITIONS = [
        'Pending' => ['Active'],
        'Active' => ['Sold', 'Expired', 'Cancelled'],
    ];

    public function assertTransition(string $to): void
    {
        $allowed = static::ALLOWED_TRANSITIONS[$this->status] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \InvalidArgumentException("Transition {$this->status} -> {$to} not allowed");
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function close(): void
    {
        // TODO: implement close
    }

    public function extend($days): void
    {
        // TODO: implement extend
    }

    public function cancel(): void
    {
        // TODO: implement cancel
    }

    public function isExpired(): ?bool
    {
        // TODO: implement is_expired
        return null;
    }

    public function finalizeAuction(): void
    {
        // TODO: implement finalize_auction
    }

}
