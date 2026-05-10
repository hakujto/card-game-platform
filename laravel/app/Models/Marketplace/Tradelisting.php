<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;
use App\Models\Cards\Card;

class Tradelisting extends Model
{
    protected $table = 'tradelistings';

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

}
