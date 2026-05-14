<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Coupon extends Model
{
    protected $table = 'coupons';

    protected $fillable = ['code', 'discount_type', 'discount_value', 'min_order_value', 'max_uses', 'uses_count', 'valid_from', 'valid_until', 'is_active'];

    protected $casts = [
        'discount_value' => 'decimal:2',
        'min_order_value' => 'decimal:2',
        'valid_from' => 'datetime',
        'valid_until' => 'datetime',
        'is_active' => 'boolean',
    ];

    const DISCOUNT_TYPE_VALUES = ['Percent', 'Fixed'];

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->valid_until === null || ($this->valid_from !== null && $this->valid_until > $this->valid_from)))) {
            $errors['valid_until_after_valid_from'] = 'Coupon expiry must be after its start date';
        }
        if (!(($this->discount_value === null || (float)$this->discount_value > (float)0))) {
            $errors['discount_value_positive'] = 'Discount value must be greater than zero';
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
        if ($this->discount_type === 'Percent' && !(($this->discount_value === null || ($this->discount_value >= 1 && $this->discount_value <= 100)))) {
            throw new \RuntimeException('Percent discount must be between 1 and 100');
        }
        if ($this->max_uses !== null && !(($this->uses_count === null || ($this->max_uses !== null && $this->uses_count <= $this->max_uses)))) {
            throw new \RuntimeException('Coupon uses count cannot exceed max_uses');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function isValid(): bool
    {
        throw new \RuntimeException('is_valid not implemented');
    }

    public function isApplicableToOrder($order_total): bool
    {
        throw new \RuntimeException('is_applicable_to_order not implemented');
    }

    public function redeem(): void
    {
        throw new \RuntimeException('redeem not implemented');
    }

    public function deactivate(): void
    {
        throw new \RuntimeException('deactivate not implemented');
    }

}
