<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class MatchRecord extends Model
{
    protected $table = 'matches';

    protected $fillable = ['table_number', 'status', 'player1_wins', 'player2_wins', 'started_at', 'ended_at', 'result_notes', 'round_id', 'player1_id', 'player2_id'];

    protected $casts = [
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Pending', 'Active', 'Completed', 'BYE', 'Draw'];

    public function round(): BelongsTo
    {
        return $this->belongsTo(TournamentRound::class, 'round_id');
    }

    public function player1(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player1_id');
    }

    public function player2(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player2_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!((($this->player1_wins === null || $this->player1_wins >= 0) && ($this->player2_wins === null || $this->player2_wins >= 0)))) {
            $errors['wins_not_negative'] = 'Win counts must not be negative';
        }
        if (!((($this->player1_wins === null || ($this->player1_wins >= 0 && $this->player1_wins <= 2)) && ($this->player2_wins === null || ($this->player2_wins >= 0 && $this->player2_wins <= 2))))) {
            $errors['max_three_games'] = 'Win counts cannot exceed 2 in a best-of-3 match';
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
        if ($this->status === 'BYE' && $this->player2 !== null) {
            throw new \RuntimeException('BYE match must not have a second player');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function recordResult($p1_wins, $p2_wins): void
    {
        throw new \RuntimeException('record_result not implemented');
    }

    public function determineWinner(): bool
    {
        throw new \RuntimeException('determine_winner not implemented');
    }

    public function draw(): void
    {
        throw new \RuntimeException('draw not implemented');
    }

}
