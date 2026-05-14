<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class OrderItem extends Model
{
    protected $table = 'order_items';

    protected $fillable = ['quantity', 'price_at_purchase', 'foil', 'order_id', 'product_id'];

    protected $casts = [
        'price_at_purchase' => 'decimal:2',
        'foil' => 'boolean',
    ];

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class, 'order_id');
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->quantity === null || $this->quantity > 0))) {
            $errors['quantity_positive'] = 'Order item quantity must be greater than zero';
        }
        if (!(($this->price_at_purchase === null || (float)$this->price_at_purchase >= (float)0))) {
            $errors['price_not_negative'] = 'Price at purchase must not be negative';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function lineTotal(): string
    {
        throw new \RuntimeException('line_total not implemented');
    }

}
