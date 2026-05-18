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

    protected $fillable = ['status', 'draft_type', 'seats', 'completed_at', 'card_set_id'];

    protected $casts = [
        'completed_at' => 'datetime',
    ];

    const STATUS_VALUES = ['WaitingForPlayers', 'Drafting', 'Completed', 'Abandoned'];
    const DRAFT_TYPE_VALUES = ['Booster', 'Cube', 'Rochester'];

    public function cardSet(): BelongsTo
    {
        return $this->belongsTo(CardSet::class, 'card_set_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->seats === null || ($this->seats >= 2 && $this->seats <= 16)))) {
            $errors['seats_range'] = 'Draft session must have between 2 and 16 seats';
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

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        throw new \RuntimeException('start not implemented');
    }

    public function abandon(): void
    {
        throw new \RuntimeException('abandon not implemented');
    }

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function isFull(): bool
    {
        throw new \RuntimeException('is_full not implemented');
    }

}
