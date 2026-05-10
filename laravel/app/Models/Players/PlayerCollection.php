<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class PlayerCollection extends Model
{
    protected $table = 'player_collections';

    protected $fillable = ['quantity', 'foil', 'condition', 'acquired_at', 'acquired_via', 'player_id', 'card_id'];

    protected $casts = [
        'foil' => 'boolean',
        'acquired_at' => 'datetime',
    ];

    const CONDITION_VALUES = ['Mint', 'NearMint', 'Excellent', 'Good', 'Played'];
    const ACQUIRED_VIA_VALUES = ['Purchase', 'Trade', 'TournamentReward', 'Pack', 'Craft'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

}
