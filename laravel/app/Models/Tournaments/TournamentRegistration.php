<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;
use App\Models\Cards\Deck;

class TournamentRegistration extends Model
{
    protected $table = 'tournament_registrations';

    protected $fillable = ['status', 'seed', 'final_standing', 'points_earned', 'registered_at', 'tournament_id', 'player_id', 'deck_id'];

    protected $casts = [
        'registered_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Registered', 'Waitlisted', 'Withdrawn', 'Disqualified'];

    public function tournament(): BelongsTo
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function deck(): BelongsTo
    {
        return $this->belongsTo(Deck::class, 'deck_id');
    }

}
