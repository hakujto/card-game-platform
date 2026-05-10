<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class AwardedPrize extends Model
{
    protected $table = 'awarded_prizes';

    protected $fillable = ['final_placement', 'awarded_at', 'claimed', 'claimed_at', 'prize_id', 'player_id'];

    protected $casts = [
        'awarded_at' => 'datetime',
        'claimed' => 'boolean',
        'claimed_at' => 'datetime',
    ];

    public function prize(): BelongsTo
    {
        return $this->belongsTo(TournamentPrize::class, 'prize_id');
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

}
