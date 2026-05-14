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
