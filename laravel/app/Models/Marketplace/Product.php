<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;
use App\Models\Cards\CardSet;

class Product extends Model
{
    protected $table = 'products';

    protected $fillable = ['name', 'product_type', 'price', 'stock', 'active', 'discount_percent', 'description', 'image_url', 'featured', 'card_id', 'card_set_id'];

    protected $casts = [
        'price' => 'decimal:2',
        'active' => 'boolean',
        'featured' => 'boolean',
    ];

    const PRODUCT_TYPE_VALUES = ['SingleCard', 'BoosterPack', 'Bundle', 'PreconstructedDeck', 'Accessory'];

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    public function cardSet(): BelongsTo
    {
        return $this->belongsTo(CardSet::class, 'card_set_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->price === null || (float)$this->price > (float)0))) {
            $errors['price_positive'] = 'Product price must be greater than zero';
        }
        if (!(($this->stock === null || $this->stock >= 0))) {
            $errors['stock_not_negative'] = 'Product stock must not be negative';
        }
        if (!(($this->discount_percent === null || ($this->discount_percent >= 0 && $this->discount_percent <= 100)))) {
            $errors['discount_percent_range'] = 'Product discount percent must be between 0 and 100';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function activate(): void
    {
        throw new \RuntimeException('activate not implemented');
    }

    public function deactivate(): void
    {
        throw new \RuntimeException('deactivate not implemented');
    }

    public function applyDiscount($percent): string
    {
        throw new \RuntimeException('apply_discount not implemented');
    }

    public function restock($quantity): void
    {
        throw new \RuntimeException('restock not implemented');
    }

    public function effectivePrice(): string
    {
        throw new \RuntimeException('effective_price not implemented');
    }

    public function isInStock(): bool
    {
        throw new \RuntimeException('is_in_stock not implemented');
    }

}
