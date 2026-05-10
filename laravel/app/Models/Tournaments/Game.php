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

}
