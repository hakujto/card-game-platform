<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class Game extends Model
{
    protected $table = 'games';

    protected $fillable = ['game_number', 'winner_side', 'turns_played', 'duration_seconds', 'ended_by', 'replay_url', 'match_id', 'winner_id'];

    const WINNER_SIDE_VALUES = ['Player1', 'Player2', 'Draw'];
    const ENDED_BY_VALUES = ['Normal', 'Timeout', 'Concession', 'DrawOffer'];

    public function match(): BelongsTo
    {
        return $this->belongsTo(MatchRecord::class, 'match_id');
    }

    public function winner(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'winner_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->game_number === null || ($this->game_number >= 1 && $this->game_number <= 3)))) {
            $errors['game_number_range'] = 'Game number must be between 1 and 3 (best-of-3)';
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
        if ($this->turns_played !== null && !(($this->turns_played === null || $this->turns_played > 0))) {
            throw new \RuntimeException('Turns played must be greater than zero');
        }
        if ($this->duration_seconds !== null && !(($this->duration_seconds === null || $this->duration_seconds > 0))) {
            throw new \RuntimeException('Game duration must be greater than zero');
        }
        if ($this->winner_side === 'Draw' && $this->winner !== null) {
            throw new \RuntimeException('A draw cannot have a winner');
        }
        if (($this->winner_side !== null && $this->winner_side !== 'Draw') && $this->winner === null) {
            throw new \RuntimeException('A decisive game must have a winner player set');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function recordWinner($winner_side): void
    {
        throw new \RuntimeException('record_winner not implemented');
    }

    public function durationMinutes(): string
    {
        throw new \RuntimeException('duration_minutes not implemented');
    }

}
