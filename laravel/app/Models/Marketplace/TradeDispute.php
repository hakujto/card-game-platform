<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class TradeDispute extends Model
{
    protected $table = 'trade_disputes';

    protected $fillable = ['status', 'reason', 'description', 'resolution', 'opened_at', 'resolved_at', 'transaction_id', 'opened_by_id', 'resolved_by_id'];

    protected $casts = [
        'opened_at' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Open', 'UnderReview', 'Resolved', 'Escalated'];
    const REASON_VALUES = ['ItemNotReceived', 'ItemNotAsDescribed', 'FraudSuspected', 'Other'];

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(TradeTransaction::class, 'transaction_id');
    }

    public function openedBy(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'opened_by_id');
    }

    public function resolvedBy(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'resolved_by_id');
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->resolved_at !== null && !($this->status === 'Resolved')) {
            throw new \RuntimeException('resolved_at_requires_terminal_status');
        }
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    const ALLOWED_TRANSITIONS = [
        'Open' => ['UnderReview'],
        'UnderReview' => ['Resolved', 'Escalated'],
        'Escalated' => ['Resolved'],
    ];

    public function assertTransition(string $to): void
    {
        $allowed = static::ALLOWED_TRANSITIONS[$this->status] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \InvalidArgumentException("Transition {$this->status} -> {$to} not allowed");
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function escalate(): void
    {
        // TODO: implement escalate
    }

    public function resolve($resolution_text): void
    {
        // TODO: implement resolve
    }

    public function closeResolved(): void
    {
        // TODO: implement close_resolved
    }

    public function review(): void
    {
        // TODO: implement review
    }

}
