<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class DraftPick extends Model
{
    protected $table = 'draft_picks';

    protected $fillable = ['pick_number', 'pack_number', 'picked_at', 'participant_id', 'card_id'];

    protected $casts = [
        'picked_at' => 'datetime',
    ];

    public function participant(): BelongsTo
    {
        return $this->belongsTo(DraftParticipant::class, 'participant_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->pick_number === null || $this->pick_number > 0))) {
            $errors['pick_number_positive'] = 'Pick number must be greater than zero';
        }
        if (!(($this->pack_number === null || ($this->pack_number >= 1 && $this->pack_number <= 3)))) {
            $errors['pack_number_range'] = 'Pack number must be between 1 and 3';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function isFirstPick(): bool
    {
        throw new \RuntimeException('is_first_pick not implemented');
    }

}
