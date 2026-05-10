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

}
