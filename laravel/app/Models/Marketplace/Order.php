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

    // ── Lifecycle state machine ──────────────────────────────────────
    const ALLOWED_TRANSITIONS = [
        'Pending' => ['Paid', 'Cancelled'],
        'Paid' => ['Processing', 'Cancelled'],
        'Processing' => ['Shipped'],
        'Shipped' => ['Completed'],
        'Completed' => ['Refunded'],
    ];

    public function assertTransition(string $to): void
    {
        $allowed = static::ALLOWED_TRANSITIONS[$this->status] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \InvalidArgumentException("Transition {$this->status} -> {$to} not allowed");
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function cancel(): void
    {
        // TODO: implement cancel
    }

    public function pay($payment_ref): ?bool
    {
        // TODO: implement pay
        return null;
    }

    public function processPayment(): ?bool
    {
        // TODO: implement process_payment
        return null;
    }

    public function calculateTotal(): ?string
    {
        // TODO: implement calculate_total
        return null;
    }

    public function applyDiscount($percent): ?string
    {
        // TODO: implement apply_discount
        return null;
    }

    public function refund(): void
    {
        // TODO: implement refund
    }

    public function notifyShipped(): void
    {
        // TODO: implement notify_shipped
    }

}
