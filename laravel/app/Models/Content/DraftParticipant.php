<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class DraftParticipant extends Model
{
    protected $table = 'draft_participants';

    protected $fillable = ['seat_number', 'joined_at', 'session_id', 'player_id'];

    protected $casts = [
        'joined_at' => 'datetime',
    ];

    public function session(): BelongsTo
    {
        return $this->belongsTo(DraftSession::class, 'session_id');
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->seat_number === null || $this->seat_number > 0))) {
            $errors['seat_number_positive'] = 'Seat number must be greater than zero';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function pickCard($card_id, $pack_number): void
    {
        throw new \RuntimeException('pick_card not implemented');
    }

    public function draftedCardCount(): int
    {
        throw new \RuntimeException('drafted_card_count not implemented');
    }

}
