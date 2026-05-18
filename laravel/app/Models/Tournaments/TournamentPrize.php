<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class TournamentPrize extends Model
{
    protected $table = 'tournament_prizes';

    protected $fillable = ['placement_from', 'placement_to', 'prize_type', 'amount', 'description', 'packs_count', 'season_points', 'tournament_id'];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    const PRIZE_TYPE_VALUES = ['Currency', 'Cards', 'BoosterPacks', 'Trophy', 'SeasonPoints', 'Mixed'];

    public function tournament(): BelongsTo
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->placement_to === null || ($this->placement_from !== null && $this->placement_to >= $this->placement_from)))) {
            $errors['placement_range_valid'] = 'placement_to must be greater than or equal to placement_from';
        }
        if (!(($this->placement_from === null || $this->placement_from > 0))) {
            $errors['placement_from_positive'] = 'placement_from must be greater than zero';
        }
        if (!(($this->amount === null || (float)$this->amount >= (float)0))) {
            $errors['amount_not_negative'] = 'Prize amount must not be negative';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function appliesToPlacement($placement): bool
    {
        throw new \RuntimeException('applies_to_placement not implemented');
    }

    public function awardToPlayer($player_id): void
    {
        throw new \RuntimeException('award_to_player not implemented');
    }

}
