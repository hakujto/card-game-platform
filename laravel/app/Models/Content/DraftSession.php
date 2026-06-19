<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\CardSet;

class DraftSession extends Model
{
    protected $table = 'draft_sessions';

    protected $fillable = ['status', 'draft_type', 'seats', 'time_per_pick_seconds', 'completed_at', 'card_set_id'];

    protected $casts = [
        'completed_at' => 'datetime',
    ];

    const STATUS_VALUES = ['WaitingForPlayers', 'Drafting', 'Completed', 'Abandoned'];
    const DRAFT_TYPE_VALUES = ['Booster', 'Cube', 'Rochester'];

    public function cardSet(): BelongsTo
    {
        return $this->belongsTo(CardSet::class, 'card_set_id');
    }

    public function participants(): HasMany
    {
        return $this->hasMany(DraftParticipant::class, 'session_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->seats === null || ($this->seats >= 2 && $this->seats <= 16)))) {
            $errors['seats_range'] = 'Draft session must have between 2 and 16 seats';
        }
        if (!(($this->time_per_pick_seconds === null || $this->time_per_pick_seconds > 0))) {
            $errors['time_per_pick_positive'] = 'Time per pick must be greater than zero';
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
        if ($this->completed_at !== null && !($this->status === 'Completed')) {
            throw new \RuntimeException('completed_at can only be set when draft status is Completed');
        }
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    const ALLOWED_TRANSITIONS = [
        'WaitingForPlayers' => ['Drafting', 'Abandoned'],
        'Drafting' => ['Completed', 'Abandoned'],
    ];

    public function assertTransition(string $to): void
    {
        $allowed = static::ALLOWED_TRANSITIONS[$this->status] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \InvalidArgumentException("Transition {$this->status} -> {$to} not allowed");
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        // TODO: implement start
    }

    public function abandon(): void
    {
        // TODO: implement abandon
    }

    public function complete(): void
    {
        // TODO: implement complete
    }

    public function isFull(): ?bool
    {
        // TODO: implement is_full
        return null;
    }

}
