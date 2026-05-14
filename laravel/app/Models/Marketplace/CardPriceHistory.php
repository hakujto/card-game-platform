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

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!((($this->min_price === null || ($this->avg_price !== null && (float)$this->min_price <= (float)$this->avg_price)) && ($this->avg_price === null || ($this->max_price !== null && (float)$this->avg_price <= (float)$this->max_price))))) {
            $errors['price_bounds_consistent'] = 'min_price <= avg_price <= max_price must hold';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function priceChangePercent($previous_avg): string
    {
        throw new \RuntimeException('price_change_percent not implemented');
    }

    public function isPriceSpike($threshold_percent): bool
    {
        throw new \RuntimeException('is_price_spike not implemented');
    }

}
