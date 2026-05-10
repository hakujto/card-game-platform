<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class CardPriceHistory extends Model
{
    protected $table = 'card_price_histories';

    protected $fillable = ['price_date', 'avg_price', 'min_price', 'max_price', 'volume', 'foil', 'card_id'];

    protected $casts = [
        'price_date' => 'date',
        'avg_price' => 'decimal:2',
        'min_price' => 'decimal:2',
        'max_price' => 'decimal:2',
        'foil' => 'boolean',
    ];

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

}
