<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class Order extends Model
{
    protected $table = 'orders';

    protected $fillable = ['status', 'total', 'discount_applied', 'currency', 'payment_method', 'payment_reference', 'shipping_address', 'tracking_number', 'paid_at', 'shipped_at', 'player_id', 'coupon_id'];

    protected $casts = [
        'total' => 'decimal:2',
        'discount_applied' => 'decimal:2',
        'paid_at' => 'datetime',
        'shipped_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Pending', 'Paid', 'Processing', 'Shipped', 'Completed', 'Cancelled', 'Refunded'];
    const PAYMENT_METHOD_VALUES = ['Card', 'PayPal', 'Crypto', 'PlatformCredits'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function coupon(): BelongsTo
    {
        return $this->belongsTo(Coupon::class, 'coupon_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->total === null || (float)$this->total >= (float)0))) {
            $errors['total_not_negative'] = 'Order total must not be negative';
        }
        if (!(($this->discount_applied === null || ($this->total !== null && (float)$this->discount_applied <= (float)$this->total)))) {
            $errors['discount_not_exceed_total'] = 'Discount applied cannot exceed order total';
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
        if ($this->status === 'Paid' && $this->paid_at === null) {
            throw new \RuntimeException('Paid order must have paid_at set');
        }
        if ($this->status === 'Shipped' && $this->tracking_number === null) {
            throw new \RuntimeException('Shipped order must have a tracking number');
        }
        if ($this->shipped_at !== null && !($this->status === 'Shipped')) {
            throw new \RuntimeException('shipped_at_requires_shipped_status');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function cancel(): void
    {
        throw new \RuntimeException('cancel not implemented');
    }

    public function pay($payment_ref): bool
    {
        throw new \RuntimeException('pay not implemented');
    }

    public function calculateTotal(): string
    {
        throw new \RuntimeException('calculate_total not implemented');
    }

    public function applyDiscount($percent): string
    {
        throw new \RuntimeException('apply_discount not implemented');
    }

    public function refund(): void
    {
        throw new \RuntimeException('refund not implemented');
    }

    public function notifyShipped(): void
    {
        throw new \RuntimeException('notify_shipped not implemented');
    }

}
